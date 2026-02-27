#' @title ActiveCampaign Users
#' @name ac_users
#' @description Fetch user (team member) data.
NULL

#' List All Users
#'
#' @return A tibble of users
#' @export
ac_users <- function() {
  ac_paginate("users", "users")
}
