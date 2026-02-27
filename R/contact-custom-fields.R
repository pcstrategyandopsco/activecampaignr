#' @title ActiveCampaign Contact Custom Fields
#' @name ac_contact_custom_fields
#' @description Fetch and pivot custom field data for contacts.
NULL

#' List Contact Custom Field Definitions
#'
#' @return A tibble of field definitions
#' @export
ac_contact_custom_fields <- function() {
  ac_paginate("fields", "fields")
}

#' Get Contact Custom Fields in Wide Format
#'
#' @param contact_id Optional contact ID(s) to filter by
#' @return A tibble with `contact_id` + one column per custom field
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
