#' @title ActiveCampaign Request Builder
#' @name ac_request
#' @description Low-level request construction, pagination, and rate limiting.
NULL

#' Build an ActiveCampaign API Request
#'
#' Constructs an httr2 request object with authentication headers,
#' rate limiting, and retry logic pre-configured.
#'
#' @param endpoint API endpoint path (e.g., `"deals"`, `"contacts/123"`)
#' @param method HTTP method: `"GET"`, `"POST"`, `"PUT"`, `"DELETE"`
#' @param body Request body (list), auto-serialized to JSON for POST/PUT
#' @param query Named list of query parameters
#' @return An httr2 request object
#' @keywords internal
ac_request <- function(endpoint, method = "GET", body = NULL, query = NULL) {
  ac_check_auth()

  url <- paste0(the$base_url, "/api/3/", endpoint)

  req <- httr2::request(url) |>
    httr2::req_headers("Api-Token" = the$api_key) |>
    httr2::req_user_agent("activecampaignr (https://github.com/peeyooshchandra/activecampaignr)") |>
    httr2::req_throttle(rate = 4 / 1) |>
    httr2::req_retry(max_tries = 3, backoff = ~ 2) |>
    httr2::req_method(method)

  if (!is.null(query)) {
    req <- httr2::req_url_query(req, !!!query)
  }

  if (!is.null(body) && method %in% c("POST", "PUT")) {
    req <- httr2::req_body_json(req, body)
  }

  req
}

#' Perform a Request and Parse the Response
#'
#' Executes the request and returns parsed JSON as a list.
#'
#' @param req An httr2 request object
#' @return Parsed response body as a list
#' @keywords internal
ac_perform <- function(req) {
  resp <- httr2::req_perform(req)
  httr2::resp_body_json(resp)
}

#' Auto-Paginate an ActiveCampaign API Endpoint
#'
#' Fetches all pages from a paginated endpoint. ActiveCampaign uses
#' offset-based pagination with a `meta.total` field.
#'
#' @param endpoint API endpoint path (e.g., `"deals"`)
#' @param entity_key The key in the response containing the entity list
#'   (e.g., `"deals"`, `"contacts"`)
#' @param query Additional query parameters (filters, sorting, etc.)
#' @param limit Number of records per page (default: 100, AC max)
#' @param .progress Optional progressr callback (`p = NULL` for none)
#' @return A tibble of all records
#' @keywords internal
ac_paginate <- function(endpoint, entity_key, query = list(), limit = 100L,
                        .progress = NULL) {
  offset <- 0L
  total <- NA_integer_
  results <- list()

  repeat {
    page_query <- c(query, list(limit = limit, offset = offset))
    req <- ac_request(endpoint, query = page_query)
    data <- ac_perform(req)

    total <- as.integer(data$meta$total %||% 0L)

    records <- data[[entity_key]]
    if (is.null(records) || length(records) == 0) break

    page_df <- ac_parse_records(records)
    results <- c(results, list(page_df))

    if (!is.null(.progress)) {
      .progress(message = glue::glue(
        "{entity_key}: {min(offset + limit, total)}/{total}"
      ))
    }

    offset <- offset + limit
    if (offset >= total) break
  }

  if (length(results) == 0) {
    return(tibble::tibble())
  }

  dplyr::bind_rows(results)
}

#' Parse a List of API Records into a Tibble
#'
#' Converts a list of records (each a named list) into a flat tibble
#' with snake_case column names and proper types.
#'
#' @param records A list of named lists from the API response
#' @return A tibble
#' @keywords internal
ac_parse_records <- function(records) {
  if (length(records) == 0) return(tibble::tibble())

  # Each record is a named list; bind into tibble

  df <- purrr::map_dfr(records, function(rec) {
    # Flatten: drop nested lists/NULLs, keep scalars
    rec <- purrr::compact(rec)
    scalars <- purrr::keep(rec, ~ is.atomic(.) && length(.) == 1)
    tibble::as_tibble(scalars)
  })

  # Clean column names
  df <- janitor::clean_names(df)

  # Coerce common types
  ac_coerce_types(df)
}

#' Coerce Common Column Types
#'
#' Converts date columns to POSIXct and keeps IDs as character.
#'
#' @param df A tibble
#' @return A tibble with coerced types
#' @keywords internal
ac_coerce_types <- function(df) {
  tz <- ac_get_tz()
  date_cols <- intersect(
    names(df),
    c("cdate", "mdate", "created_timestamp", "updated_timestamp",
      "created_date", "sdate", "edate")
  )

  for (col in date_cols) {
    df[[col]] <- tryCatch(
      as.POSIXct(df[[col]], tz = tz),
      error = function(e) df[[col]]
    )
  }

  # Keep IDs as character to avoid integer overflow
  id_cols <- intersect(names(df), c("id", "owner", "contact", "group",
                                     "stage", "deal", "userid"))
  for (col in id_cols) {
    df[[col]] <- as.character(df[[col]])
  }

  df
}

#' Perform a Single-Entity GET Request
#'
#' @param endpoint API endpoint (e.g., `"deals/123"`)
#' @param entity_key Response key (e.g., `"deal"`)
#' @return A single-row tibble
#' @keywords internal
ac_get_one <- function(endpoint, entity_key) {
  data <- ac_perform(ac_request(endpoint))
  record <- data[[entity_key]]
  if (is.null(record)) {
    cli::cli_abort("Entity not found at {.code {endpoint}}")
  }
  ac_parse_records(list(record))
}

#' Perform a Create (POST) Request
#'
#' @param endpoint API endpoint
#' @param entity_key Wrapper key for the body (e.g., `"deal"`)
#' @param body Named list of fields
#' @return A single-row tibble of the created entity
#' @keywords internal
ac_post_one <- function(endpoint, entity_key, body) {
  wrapped <- stats::setNames(list(body), entity_key)
  req <- ac_request(endpoint, method = "POST", body = wrapped)
  data <- ac_perform(req)
  ac_parse_records(list(data[[entity_key]]))
}

#' Perform an Update (PUT) Request
#'
#' @param endpoint API endpoint (e.g., `"deals/123"`)
#' @param entity_key Wrapper key for the body
#' @param body Named list of fields to update
#' @return A single-row tibble of the updated entity
#' @keywords internal
ac_put_one <- function(endpoint, entity_key, body) {
  wrapped <- stats::setNames(list(body), entity_key)
  req <- ac_request(endpoint, method = "PUT", body = wrapped)
  data <- ac_perform(req)
  ac_parse_records(list(data[[entity_key]]))
}

#' Perform a DELETE Request
#'
#' @param endpoint API endpoint (e.g., `"deals/123"`)
#' @return Invisibly returns `TRUE` on success
#' @keywords internal
ac_delete_one <- function(endpoint) {
  req <- ac_request(endpoint, method = "DELETE")
  httr2::req_perform(req)
  invisible(TRUE)
}
