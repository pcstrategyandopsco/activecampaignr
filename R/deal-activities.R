#' @title ActiveCampaign Deal Activities
#' @name ac_deal_activities
#' @description Fetch deal activity logs and extract won dates.
NULL

#' Get Deal Activities
#'
#' Retrieves the activity log for a specific deal, including status
#' changes, notes, and other events.
#'
#' @param deal_id Deal ID
#' @return A tibble of activity records
#' @export
ac_deal_activities <- function(deal_id) {
  endpoint <- paste0("deals/", deal_id, "/dealActivities")

  # Deal activities may not use standard pagination
  data <- ac_perform(ac_request(endpoint))
  records <- data$dealActivities
  if (is.null(records) || length(records) == 0) {
    return(tibble::tibble())
  }
  ac_parse_records(records)
}

#' Extract the Actual Won Date for a Deal
#'
#' Parses the deal activity log to find the first time the deal was
#' moved to "Won" status. This is more reliable than `mdate` which
#' reflects the last modification time.
#'
#' @param deal_id Deal ID
#' @return A POSIXct datetime, or `NA` if no won event found
#' @export
#' @examples
#' \dontrun{
#' won_date <- ac_deal_won_date("12345")
#' }
ac_deal_won_date <- function(deal_id) {
  activities <- ac_deal_activities(deal_id)

  if (nrow(activities) == 0) return(NA_real_)

  # Look for status change events where action = won (status 1)
  # AC stores: dataType = "status", dataAction = "1" for Won

  type_col <- intersect(names(activities),
                        c("data_type", "datatype", "action"))
  action_col <- intersect(names(activities),
                          c("data_action", "dataaction", "info"))

  if (length(type_col) == 0 || length(action_col) == 0) {
    return(NA_real_)
  }

  won_events <- activities |>
    dplyr::filter(
      .data[[type_col[1]]] == "status",
      .data[[action_col[1]]] == "1"
    )

  if (nrow(won_events) == 0) return(NA_real_)

  date_col <- intersect(names(won_events), c("cdate", "tstamp", "created_date"))
  if (length(date_col) == 0) return(NA_real_)

  dates <- as.POSIXct(won_events[[date_col[1]]], tz = ac_get_tz())
  min(dates, na.rm = TRUE)
}

#' Batch Extract Won Dates for Multiple Deals
#'
#' Iterates over deal IDs, fetching activity logs and extracting
#' the actual won date for each. Includes rate limiting.
#'
#' @param deal_ids Character vector of deal IDs
#' @param .progress Optional progressr callback
#' @return A tibble with columns: deal_id, won_date
#' @export
ac_deal_won_dates <- function(deal_ids, .progress = NULL) {
  results <- purrr::map(deal_ids, function(did) {
    won <- tryCatch(
      ac_deal_won_date(did),
      error = function(e) NA_real_
    )
    if (!is.null(.progress)) {
      .progress(message = glue::glue("Won dates: {which(deal_ids == did)}/{length(deal_ids)}"))
    }
    tibble::tibble(deal_id = as.character(did), won_date = won)
  })

  dplyr::bind_rows(results)
}
