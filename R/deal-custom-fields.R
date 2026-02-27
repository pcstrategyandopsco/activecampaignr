#' @title ActiveCampaign Deal Custom Fields
#' @name ac_deal_custom_fields
#' @description Fetch and pivot custom field data for deals.
NULL

#' List Deal Custom Field Definitions
#'
#' Returns the field definitions (metadata), not the values.
#'
#' @return A tibble with columns: id, title, type, etc.
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
#' @export
ac_deal_custom_field_values <- function(deal_id = NULL) {
  query <- list()
  if (!is.null(deal_id)) {
    query[["filters[dealId]"]] <- paste0(deal_id, collapse = ",")
  }

  ac_paginate("dealCustomFieldData", "dealCustomFieldData", query = query)
}

#' Get Deal Custom Fields in Wide Format
#'
#' Fetches custom field values and pivots them so each deal is one row
#' and each custom field is a column. Column names are the field labels.
#'
#' @param deal_id Optional deal ID(s) to filter by
#' @return A tibble with `deal_id` + one column per custom field
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
