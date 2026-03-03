#' @title ActiveCampaign Contact Custom Fields
#' @name ac_contact_custom_fields
#' @description Fetch and pivot custom field data for contacts.
NULL

#' List Contact Custom Field Definitions
#'
#' Returns the field definitions (metadata), not the values. Each row
#' contains a field's `id`, `title`, and `type`.
#'
#' To look up field IDs by name (e.g., for use in [ac_update_contact()]),
#' use [ac_contact_field_ids()] which builds a cached, named registry
#' from these definitions.
#'
#' @return A tibble of field definitions
#' @seealso [ac_contact_field_ids()] for a cached name-to-ID registry,
#'   [ac_contact_custom_fields_wide()] for pivoted values per contact.
#' @export
ac_contact_custom_fields <- function() {
  ac_paginate("fields", "fields")
}

#' Get Contact Custom Fields in Wide Format
#'
#' @param contact_id Optional contact ID(s) to filter by
#' @return A tibble with `contact_id` + one column per custom field
#' @seealso [ac_contact_custom_fields()] for field definitions,
#'   [ac_contact_field_ids()] for looking up field IDs by name when
#'   writing values back via [ac_update_contact()].
#' @export
ac_contact_custom_fields_wide <- function(contact_id = NULL) {
  query <- list()
  if (!is.null(contact_id)) {
    query[["filters[contactId]"]] <- paste0(contact_id, collapse = ",")
  }

  values <- ac_paginate("fieldValues", "fieldValues", query = query)
  if (nrow(values) == 0) {
    return(tibble::tibble(contact_id = character()))
  }

  fields <- ac_contact_custom_fields()

  # Build label lookup
  label_lookup <- fields |>
    dplyr::select(field_id = "id",
                  field_label = dplyr::any_of(c("title", "field_label"))) |>
    dplyr::mutate(field_id = as.character(.data$field_id))

  # Find columns dynamically
  contact_col <- intersect(names(values), c("contact", "contact_id", "contactid"))
  field_col <- intersect(names(values), c("field", "field_id", "fieldid"))
  val_col <- intersect(names(values), c("value", "field_value"))

  if (length(contact_col) == 0 || length(field_col) == 0 || length(val_col) == 0) {
    cli::cli_warn("Unexpected column names in fieldValues response")
    return(tibble::tibble(contact_id = character()))
  }

  joined <- values |>
    dplyr::mutate(
      .contact_id = as.character(.data[[contact_col[1]]]),
      .field_id = as.character(.data[[field_col[1]]]),
      .value = as.character(.data[[val_col[1]]])
    ) |>
    dplyr::left_join(label_lookup, by = c(".field_id" = "field_id")) |>
    dplyr::mutate(
      .col_name = dplyr::coalesce(.data$field_label, .data$.field_id)
    )

  wide <- joined |>
    dplyr::select(".contact_id", ".col_name", ".value") |>
    tidyr::pivot_wider(
      id_cols = ".contact_id",
      names_from = ".col_name",
      values_from = ".value",
      values_fn = ~ paste(.x, collapse = ", ")
    ) |>
    dplyr::rename(contact_id = ".contact_id")

  janitor::clean_names(wide)
}

#' Contact Custom Field ID Registry
#'
#' Returns a cached registry mapping clean field names to their IDs and
#' types. Built from [ac_contact_custom_fields()] on first call, then
#' served from memory until `ttl` expires. Use `ccf$field_name` to look
#' up a field ID by name (tab-completable in RStudio), or [ac_field_id()]
#' for validated lookups with type checking.
#'
#' Each entry stores both the field `id` and `type`. The `$` operator
#' returns just the ID for convenience. Access the full entry via
#' `ccf[["field_name"]]` to see both `$id` and `$type`.
#'
#' @param ttl Cache lifetime in minutes (default: 60)
#' @param force If `TRUE`, bypass cache and re-fetch from API
#' @return An `ac_field_registry` object (named list of
#'   `list(id, type)` entries)
#' @seealso [ac_field_id()] for validated lookups with type checking,
#'   [ac_contact_custom_fields()] for the raw field definitions tibble,
#'   [ac_contact_custom_fields_wide()] for reading field values,
#'   [ac_update_contact()] for writing field values,
#'   [ac_deal_field_ids()] for the deal equivalent.
#' @export
#' @examples
#' \dontrun{
#' ac_auth("https://yours.api-us1.com", "your-key")
#'
#' # Get contact custom field registry
#' ccf <- ac_contact_field_ids()
#' ccf$company_size  # "8"
#'
#' # See field type
#' ccf[["company_size"]]$type  # "dropdown"
#'
#' # Force refresh after field changes in AC admin
#' ccf <- ac_contact_field_ids(force = TRUE)
#'
#' # See all available fields with types
#' print(ccf)
#' }
ac_contact_field_ids <- function(ttl = 60, force = FALSE) {
  ac_check_auth()

  if (!force && !is.null(the$contact_field_registry) &&
      !is.null(the$contact_field_registry_time) &&
      difftime(Sys.time(), the$contact_field_registry_time, units = "mins") < ttl) {
    return(the$contact_field_registry)
  }

  cli::cli_inform("Fetching contact custom field definitions...")
  fields <- ac_contact_custom_fields()

  registry <- ac_build_field_registry(fields, "Contact")
  the$contact_field_registry <- registry
  the$contact_field_registry_time <- Sys.time()

  registry
}
