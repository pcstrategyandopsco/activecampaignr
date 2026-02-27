#' @title ActiveCampaign Accounts
#' @name ac_accounts
#' @description Operations for ActiveCampaign accounts (companies).
NULL

#' List All Accounts
#'
#' @param search Search string
#' @param .progress Optional progressr callback
#' @return A tibble of accounts
#' @export
ac_accounts <- function(search = NULL, .progress = NULL) {
  query <- list()
  if (!is.null(search)) query[["search"]] <- search
  ac_paginate("accounts", "accounts", query = query, .progress = .progress)
}

#' Create an Account
#'
#' @param name Account name (required)
#' @param url Account website URL
#' @param ... Additional fields
#' @return A single-row tibble
#' @export
ac_create_account <- function(name, url = NULL, ...) {
  body <- list(name = name)
  if (!is.null(url)) body$accountUrl <- url
  body <- c(body, list(...))
  ac_post_one("accounts", "account", body)
}
