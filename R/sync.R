#' @title ActiveCampaign Incremental Sync
#' @name ac_sync
#' @description Cached, incremental sync for deals and contacts.
NULL

#' Incremental Deal Sync
#'
#' Fetches deals from ActiveCampaign with intelligent caching:
#' 1. If the cache is fresh (within TTL), returns cached data
#' 2. If stored data exists, performs incremental sync (recent changes only)
#' 3. Otherwise, performs a full sync
#'
#' @param lookback_days Number of days to look back for incremental sync
#'   (default: 5)
#' @param ttl_minutes Cache time-to-live in minutes (default: 10)
#' @param force If `TRUE`, bypasses cache and fetches everything
#' @param include_custom_fields If `TRUE`, also fetches custom fields
#'   in wide format (default: `TRUE`)
#' @param .progress Optional progressr callback
#' @return A list with `$deals` (tibble) and optionally `$custom_fields`
#'   (tibble)
#' @export
#' @examples
#' \dontrun{
#' result <- ac_sync_deals()
#' deals <- result$deals
#'
#' # Force full refresh
#' result <- ac_sync_deals(force = TRUE)
#' }
ac_sync_deals <- function(lookback_days = 5, ttl_minutes = 10,
                          force = FALSE, include_custom_fields = TRUE,
                          .progress = NULL) {
  deals_path <- ac_cache_file("deals")
  cf_path <- ac_cache_file("deal_custom_fields")

  # Check cache freshness
  if (!force && file.exists(deals_path)) {
    age_min <- as.numeric(
      difftime(Sys.time(), file.info(deals_path)$mtime, units = "mins")
    )
    if (age_min < ttl_minutes) {
      if (!is.null(.progress)) {
        .progress(message = glue::glue(
          "Deals: cache fresh ({round(age_min, 1)} min old)"
        ))
      }
      cli::cli_alert_info("Deals cache is fresh ({round(age_min, 1)} min old)")
      result <- list(deals = readRDS(deals_path))
      if (include_custom_fields && file.exists(cf_path)) {
        result$custom_fields <- readRDS(cf_path)
      }
      return(result)
    }
  }

  # Load stored data
  stored <- if (file.exists(deals_path)) readRDS(deals_path) else tibble::tibble()

  # Decide strategy
  if (force || nrow(stored) == 0) {
    if (!is.null(.progress)) .progress(message = "Deals: full sync...")
    cli::cli_alert_info("Performing full deal sync")
    deals <- ac_deals(.progress = .progress)
  } else {
    cutoff <- as.character(Sys.Date() - lookback_days)
    if (!is.null(.progress)) {
      .progress(message = glue::glue(
        "Deals: incremental sync (lookback: {lookback_days}d)"
      ))
    }
    cli::cli_alert_info("Incremental sync (lookback: {lookback_days} days)")
    modified <- ac_deals(updated_after = cutoff, .progress = .progress)
    deals <- ac_merge_records(stored, modified, id_col = "id")
  }

  # Save
  saveRDS(deals, deals_path)
  cli::cli_alert_success("Synced {nrow(deals)} deals")

  result <- list(deals = deals)

  # Custom fields
  if (include_custom_fields) {
    if (!is.null(.progress)) .progress(message = "Deals: fetching custom fields...")
    cf <- ac_deal_custom_fields_wide()
    if (nrow(cf) > 0) saveRDS(cf, cf_path)
    result$custom_fields <- cf
  }

  result
}

#' Incremental Contact Sync
#'
#' Fetches contacts with caching, similar to [ac_sync_deals()].
#'
#' @param lookback_days Days to look back for incremental sync
#' @param ttl_minutes Cache TTL in minutes
#' @param force Bypass cache
#' @param .progress Optional progressr callback
#' @return A tibble of contacts
#' @export
ac_sync_contacts <- function(lookback_days = 5, ttl_minutes = 10,
                             force = FALSE, .progress = NULL) {
  contacts_path <- ac_cache_file("contacts")

  # Check cache freshness
  if (!force && file.exists(contacts_path)) {
    age_min <- as.numeric(
      difftime(Sys.time(), file.info(contacts_path)$mtime, units = "mins")
    )
    if (age_min < ttl_minutes) {
      if (!is.null(.progress)) {
        .progress(message = glue::glue(
          "Contacts: cache fresh ({round(age_min, 1)} min old)"
        ))
      }
      cli::cli_alert_info("Contacts cache is fresh ({round(age_min, 1)} min old)")
      return(readRDS(contacts_path))
    }
  }

  stored <- if (file.exists(contacts_path)) readRDS(contacts_path) else tibble::tibble()

  if (force || nrow(stored) == 0) {
    if (!is.null(.progress)) .progress(message = "Contacts: full sync...")
    cli::cli_alert_info("Performing full contact sync")
    contacts <- ac_contacts(.progress = .progress)
  } else {
    cutoff <- as.character(Sys.Date() - lookback_days)
    if (!is.null(.progress)) {
      .progress(message = glue::glue(
        "Contacts: incremental sync (lookback: {lookback_days}d)"
      ))
    }
    cli::cli_alert_info("Incremental contact sync (lookback: {lookback_days} days)")
    modified <- ac_contacts(updated_after = cutoff, .progress = .progress)
    contacts <- ac_merge_records(stored, modified, id_col = "id")
  }

  saveRDS(contacts, contacts_path)
  cli::cli_alert_success("Synced {nrow(contacts)} contacts")

  contacts
}
