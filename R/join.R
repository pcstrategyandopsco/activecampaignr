#' @title ActiveCampaign Join Helpers
#' @name ac_join
#' @description Convenience functions that fetch entities and their custom
#'   fields, join them, and report match diagnostics.
NULL

#' Join Deals with Custom Fields
#'
#' Fetches deals and their custom fields in wide format, then left-joins
#' them by deal ID. Prints a diagnostic summary showing match counts.
#'
#' @param ... Arguments passed to [ac_deals()] (e.g., `status`, `pipeline`,
#'   `owner`, `updated_after`)
#' @return A tibble of deals with custom field columns appended
#' @export
#' @examples
#' \dontrun{
#' # All deals with custom fields
#' deals <- ac_join_deal_fields()
#'
#' # Won deals with custom fields
#' deals <- ac_join_deal_fields(status = 1)
#' }
ac_join_deal_fields <- function(...) {
  deals <- ac_deals(...)
  n_deals <- nrow(deals)

  if (n_deals == 0) {
    cli::cli_alert_warning("No deals found")
    return(deals)
  }

  cf <- ac_deal_custom_fields_wide()
  n_cf <- nrow(cf)

  if (n_cf == 0) {
    cli::cli_alert_warning(
      "{n_deals} deal{?s} fetched but no custom field data found"
    )
    return(deals)
  }

  result <- dplyr::left_join(deals, cf, by = c("id" = "deal_id"))

  n_matched <- sum(deals$id %in% cf$deal_id)
  n_unmatched <- n_deals - n_matched

  cli::cli_alert_success(
    "{n_deals} deal{?s} joined with {ncol(cf) - 1L} custom field{?s}"
  )
  if (n_unmatched > 0) {
    cli::cli_alert_info(
      "{n_matched} matched, {n_unmatched} deal{?s} with no custom fields"
    )
  }

  result
}

#' Join Contacts with Custom Fields
#'
#' Fetches contacts and their custom fields in wide format, then left-joins
#' them by contact ID. Prints a diagnostic summary showing match counts.
#'
#' @param ... Arguments passed to [ac_contacts()] (e.g., `email`, `search`,
#'   `updated_after`)
#' @return A tibble of contacts with custom field columns appended
#' @export
#' @examples
#' \dontrun{
#' # All contacts with custom fields
#' contacts <- ac_join_contact_fields()
#'
#' # Search with custom fields
#' contacts <- ac_join_contact_fields(email = "user@example.com")
#' }
ac_join_contact_fields <- function(...) {
  contacts <- ac_contacts(...)
  n_contacts <- nrow(contacts)

  if (n_contacts == 0) {
    cli::cli_alert_warning("No contacts found")
    return(contacts)
  }

  cf <- ac_contact_custom_fields_wide()
  n_cf <- nrow(cf)

  if (n_cf == 0) {
    cli::cli_alert_warning(
      "{n_contacts} contact{?s} fetched but no custom field data found"
    )
    return(contacts)
  }

  result <- dplyr::left_join(contacts, cf, by = c("id" = "contact_id"))

  n_matched <- sum(contacts$id %in% cf$contact_id)
  n_unmatched <- n_contacts - n_matched

  cli::cli_alert_success(
    "{n_contacts} contact{?s} joined with {ncol(cf) - 1L} custom field{?s}"
  )
  if (n_unmatched > 0) {
    cli::cli_alert_info(
      "{n_matched} matched, {n_unmatched} contact{?s} with no custom fields"
    )
  }

  result
}
