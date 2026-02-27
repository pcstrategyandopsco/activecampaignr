#' @title ActiveCampaign Campaigns
#' @name ac_campaigns
#' @description Fetch campaign data and performance metrics.
NULL

#' List All Campaigns
#'
#' @param .progress Optional progressr callback
#' @return A tibble of campaigns
#' @export
ac_campaigns <- function(.progress = NULL) {
  ac_paginate("campaigns", "campaigns", .progress = .progress)
}

#' Get Campaign Messages
#'
#' @param campaign_id Campaign ID
#' @return A tibble of messages for the campaign
#' @export
ac_campaign_messages <- function(campaign_id) {
  endpoint <- paste0("campaigns/", campaign_id, "/messages")
  data <- ac_perform(ac_request(endpoint))
  records <- data$messages %||% data$campaignMessages
  if (is.null(records) || length(records) == 0) return(tibble::tibble())
  ac_parse_records(records)
}
