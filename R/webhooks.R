#' @title ActiveCampaign Webhooks
#' @name ac_webhooks
#' @description Manage webhook subscriptions.
NULL

#' List All Webhooks
#'
#' @return A tibble of webhooks
#' @export
ac_webhooks <- function() {
  ac_paginate("webhooks", "webhooks")
}

#' Create a Webhook
#'
#' @param name Webhook name
#' @param url URL to receive webhook POSTs
#' @param events Character vector of event names (e.g., `"deal_add"`,
#'   `"contact_add"`, `"deal_update"`)
#' @param sources Character vector of source IDs (e.g., `"0"` for all)
#' @return A single-row tibble
#' @export
ac_create_webhook <- function(name, url, events, sources = "0") {
  body <- list(
    name = name,
    url = url,
    events = as.list(events),
    sources = as.list(sources)
  )
  ac_post_one("webhooks", "webhook", body)
}

#' Delete a Webhook
#'
#' @param id Webhook ID
#' @return Invisibly returns `TRUE`
#' @export
ac_delete_webhook <- function(id) {
  ac_delete_one(paste0("webhooks/", id))
}
