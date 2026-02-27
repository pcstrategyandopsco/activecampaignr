#' @title ActiveCampaign Deals
#' @name ac_deals
#' @description CRUD operations for ActiveCampaign deals.
NULL

#' List All Deals
#'
#' Retrieves all deals with automatic pagination. Supports filtering
#' by status, owner, pipeline, stage, and modification date.
#'
#' @param status Filter by status: `0` = open, `1` = won, `2` = lost
#' @param owner Filter by deal owner ID
#' @param pipeline Filter by pipeline (group) ID
#' @param stage Filter by stage ID
#' @param updated_after Only return deals modified after this date
#'   (format: `"YYYY-MM-DD"`)
#' @param search Search string to match against deal titles
#' @param .progress Optional progressr callback
#' @return A tibble of deals
#' @export
#' @examples
#' \dontrun{
#' # All deals
#' deals <- ac_deals()
#'
#' # Won deals only
#' won <- ac_deals(status = 1)
#'
#' # Deals modified in the last week
#' recent <- ac_deals(updated_after = Sys.Date() - 7)
#' }
ac_deals <- function(status = NULL, owner = NULL, pipeline = NULL,
                     stage = NULL, updated_after = NULL, search = NULL,
                     .progress = NULL) {
  query <- list()
  if (!is.null(status)) query[["filters[status]"]] <- as.character(status)
  if (!is.null(owner)) query[["filters[owner]"]] <- as.character(owner)
  if (!is.null(pipeline)) query[["filters[group]"]] <- as.character(pipeline)
  if (!is.null(stage)) query[["filters[stage]"]] <- as.character(stage)
  if (!is.null(updated_after)) {
    query[["filters[updated_after]"]] <- as.character(updated_after)
  }
  if (!is.null(search)) query[["filters[search]"]] <- search

  ac_paginate("deals", "deals", query = query, .progress = .progress)
}

#' Get a Single Deal
#'
#' @param id Deal ID
#' @return A single-row tibble
#' @export
ac_deal <- function(id) {
  ac_get_one(paste0("deals/", id), "deal")
}

#' Create a Deal
#'
#' @param title Deal title
#' @param value Deal value in cents (integer)
#' @param currency Currency code (e.g., `"nzd"`, `"usd"`)
#' @param pipeline Pipeline (group) ID
#' @param stage Stage ID
#' @param owner Owner (user) ID
#' @param contact Contact ID
#' @param ... Additional fields as named arguments
#' @return A single-row tibble of the created deal
#' @export
ac_create_deal <- function(title, value = 0, currency = "usd",
                           pipeline = NULL, stage = NULL, owner = NULL,
                           contact = NULL, ...) {
  body <- list(
    title = title,
    value = as.integer(value),
    currency = currency
  )
  if (!is.null(pipeline)) body$group <- as.character(pipeline)
  if (!is.null(stage)) body$stage <- as.character(stage)
  if (!is.null(owner)) body$owner <- as.character(owner)
  if (!is.null(contact)) body$contact <- as.character(contact)
  body <- c(body, list(...))

  ac_post_one("deals", "deal", body)
}

#' Update a Deal
#'
#' @param id Deal ID
#' @param ... Fields to update as named arguments (e.g., `title = "New"`,
#'   `value = 5000`, `stage = "3"`)
#' @return A single-row tibble of the updated deal
#' @export
ac_update_deal <- function(id, ...) {
  body <- list(...)
  ac_put_one(paste0("deals/", id), "deal", body)
}

#' Delete a Deal
#'
#' @param id Deal ID
#' @return Invisibly returns `TRUE`
#' @export
ac_delete_deal <- function(id) {
  ac_delete_one(paste0("deals/", id))
}
