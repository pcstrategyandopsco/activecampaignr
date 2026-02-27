#' @title ActiveCampaign Lists
#' @name ac_lists
#' @description Manage contact lists.
NULL

#' List All Lists
#'
#' @return A tibble of lists
#' @export
ac_lists <- function() {
  ac_paginate("lists", "lists")
}

#' Get Contacts on a List
#'
#' @param list_id List ID
#' @param .progress Optional progressr callback
#' @return A tibble of contacts
#' @export
ac_list_contacts <- function(list_id, .progress = NULL) {
  ac_contacts(list_id = list_id, .progress = .progress)
}
