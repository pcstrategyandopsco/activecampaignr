#' @title ActiveCampaign Deal Custom Fields
#' @name ac_deal_custom_fields
#' @description Fetch and pivot custom field data for deals.
NULL

#' List Deal Custom Field Definitions
#'
#' Returns the field definitions (metadata), not the values. Each row
#' contains a field's `id`, `field_label`, and `field_type`.
#'
#' To look up field IDs by name (e.g., for use in [ac_update_deal()]),
#' use [ac_deal_field_ids()] which builds a cached, named registry from
#' these definitions.
#'
#' @return A tibble with columns: id, field_label, field_type, etc.
#' @seealso [ac_deal_field_ids()] for a cached name-to-ID registry,
#'   [ac_deal_custom_field_values()] for raw field values,
#'   [ac_deal_custom_fields_wide()] for pivoted values per deal.
#' @export
ac_deal_custom_fields <- function() {
  ac_paginate("dealCustomFieldMeta", "dealCustomFieldMeta")
}

#' Get All Deal Custom Field Values
#'
#' Fetches the raw custom field values for all deals (long format:
#' one row per deal-field combination).
#'
#' @param deal_id Optional deal ID(s) to filter by
#' @return A tibble with columns: id, deal_id, custom_field_meta_id, custom_field_datum_value
#' @seealso [ac_deal_custom_fields()] for field definitions,
#'   [ac_deal_custom_fields_wide()] for pivoted wide format,
#'   [ac_deal_field_ids()] for looking up field IDs by name.
#' @export
ac_deal_custom_field_values <- function(deal_id = NULL) {
  if (is.null(deal_id)) {
    return(ac_paginate("dealCustomFieldData", "dealCustomFieldData"))
  }

  deal_id <- as.character(deal_id)

  if (length(deal_id) > 1) {
    cli::cli_warn(c(
      "!" = "ActiveCampaign API does not support filtering by multiple deal IDs
             in a single request.",
      "i" = "Querying {length(deal_id)} deal{?s} individually."
    ))
  }

  results <- lapply(deal_id, function(did) {
    query <- list("filters[dealId]" = did)
    ac_paginate("dealCustomFieldData", "dealCustomFieldData", query = query)
  })
  out <- dplyr::bind_rows(results)
  if (nrow(out) > 0 && "id" %in% names(out)) {
    out <- dplyr::distinct(out, .data$id, .keep_all = TRUE)
  }
  out
}

#' Get Deal Custom Fields in Wide Format
#'
#' Fetches custom field values and pivots them so each deal is one row
#' and each custom field is a column. Column names are the field labels.
#'
#' @param deal_id Optional deal ID(s) to filter by
#' @return A tibble with `deal_id` + one column per custom field
#' @seealso [ac_deal_custom_fields()] for field definitions,
#'   [ac_deal_custom_field_values()] for long-format values,
#'   [ac_deal_field_ids()] for looking up field IDs by name when
#'   writing values back via [ac_update_deal()].
#' @export
#' @examples
#' \dontrun{
#' # Wide format custom fields for all deals
#' cf <- ac_deal_custom_fields_wide()
#'
#' # For specific deals
#' cf <- ac_deal_custom_fields_wide(deal_id = c("123", "456"))
#' }
ac_deal_custom_fields_wide <- function(deal_id = NULL) {
  # Fetch values (long format)
  values <- ac_deal_custom_field_values(deal_id = deal_id)

  if (nrow(values) == 0) {
    return(tibble::tibble(deal_id = character()))
  }

  # Fetch field definitions for labels
  fields <- ac_deal_custom_fields()

  # Standardize column names for join
  val_id_col <- intersect(names(values),
                          c("custom_field_meta_id", "customfieldmetaid",
                            "custom_field_id"))
  field_id_col <- "id"

  if (length(val_id_col) == 0) {
    cli::cli_warn("Could not find custom field ID column in values")
    return(tibble::tibble(deal_id = character()))
  }

  # Join values with field labels
  label_lookup <- fields |>
    dplyr::select(field_id = dplyr::all_of(field_id_col),
                  field_label = dplyr::any_of(c("field_label", "title"))) |>
    dplyr::mutate(field_id = as.character(.data$field_id))

  # Find the deal ID column in values
  deal_col <- intersect(names(values), c("deal_id", "dealid"))
  if (length(deal_col) == 0) deal_col <- "deal_id"

  # Find the value column
  val_col <- intersect(names(values),
                       c("custom_field_datum_value", "field_value",
                         "fieldvalue", "value"))
  if (length(val_col) == 0) val_col <- names(values)[ncol(values)]

  joined <- values |>
    dplyr::mutate(
      .deal_id = as.character(.data[[deal_col[1]]]),
      .field_id = as.character(.data[[val_id_col[1]]]),
      .value = as.character(.data[[val_col[1]]])
    ) |>
    dplyr::left_join(label_lookup, by = c(".field_id" = "field_id"))

  # Use field_label as column name, fall back to field ID
  joined <- joined |>
    dplyr::mutate(
      .col_name = dplyr::coalesce(.data$field_label, .data$.field_id)
    )

  # Pivot to wide
  wide <- joined |>
    dplyr::select(".deal_id", ".col_name", ".value") |>
    tidyr::pivot_wider(
      id_cols = ".deal_id",
      names_from = ".col_name",
      values_from = ".value",
      values_fn = ~ paste(.x, collapse = ", ")
    ) |>
    dplyr::rename(deal_id = ".deal_id")

  # Clean column names
  janitor::clean_names(wide)
}

#' Deal Custom Field ID Registry
#'
#' Returns a cached registry mapping clean field names to their IDs and
#' types. Built from [ac_deal_custom_fields()] on first call, then served
#' from memory until `ttl` expires. Use `cdf$field_name` to look up a
#' field ID by name (tab-completable in RStudio), or [ac_field_id()] for
#' validated lookups with type checking.
#'
#' Each entry stores both the field `id` and `type` (e.g., `"text"`,
#' `"date"`, `"currency"`). The `$` operator returns just the ID for
#' convenience. Access the full entry via `cdf[["field_name"]]` to see
#' both `$id` and `$type`.
#'
#' @param ttl Cache lifetime in minutes (default: 60)
#' @param force If `TRUE`, bypass cache and re-fetch from API
#' @return An `ac_field_registry` object (named list of
#'   `list(id, type)` entries)
#' @seealso [ac_field_id()] for validated lookups with type checking,
#'   [ac_deal_custom_fields()] for the raw field definitions tibble,
#'   [ac_deal_custom_fields_wide()] for reading field values,
#'   [ac_update_deal()] for writing field values,
#'   [ac_contact_field_ids()] for the contact equivalent.
#' @export
#' @examples
#' \dontrun{
#' ac_auth("https://yours.api-us1.com", "your-key")
#'
#' # Get deal custom field registry (fetches on first call, cached after)
#' cdf <- ac_deal_field_ids()
#' cdf$source          # "42" (just the ID)
#' cdf$expected_close   # "17"
#'
#' # See field type
#' cdf[["source"]]$type  # "text"
#'
#' # Use in deal update
#' ac_update_deal("123", fields = list(
#'   list(customFieldId = cdf$source, fieldValue = "Google Ads"),
#'   list(customFieldId = cdf$expected_close, fieldValue = "2026-06-01")
#' ))
#'
#' # Safe lookup with type validation
#' ac_update_deal("123", fields = list(
#'   list(
#'     customFieldId = ac_field_id(cdf, "expected_close", "2026-06-01"),
#'     fieldValue = "2026-06-01"
#'   )
#' ))
#'
#' # Force refresh after field changes in AC admin
#' cdf <- ac_deal_field_ids(force = TRUE)
#'
#' # See all available fields with types
#' print(cdf)
#' }
ac_deal_field_ids <- function(ttl = 60, force = FALSE) {
  ac_check_auth()

  if (!force && !is.null(the$deal_field_registry) &&
      !is.null(the$deal_field_registry_time) &&
      difftime(Sys.time(), the$deal_field_registry_time, units = "mins") < ttl) {
    return(the$deal_field_registry)
  }

  cli::cli_inform("Fetching deal custom field definitions...")
  fields <- ac_deal_custom_fields()

  registry <- ac_build_field_registry(fields, "Deal")
  the$deal_field_registry <- registry
  the$deal_field_registry_time <- Sys.time()

  registry
}
