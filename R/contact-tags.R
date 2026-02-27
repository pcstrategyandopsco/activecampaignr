#' @title ActiveCampaign Contact Tags
#' @name ac_contact_tags
#' @description Manage tags on contacts.
NULL

#' List Tags on a Contact
#'
#' @param contact_id Contact ID
#' @return A tibble of tags
#' @export
ac_contact_tags <- function(contact_id) {
  ac_paginate(
    paste0("contacts/", contact_id, "/contactTags"),
    "contactTags"
  )
}

#' Add a Tag to a Contact
#'
#' @param contact_id Contact ID
#' @param tag_id Tag ID
#' @return A single-row tibble
#' @export
ac_add_tag <- function(contact_id, tag_id) {
  body <- list(
    contactTag = list(
      contact = as.character(contact_id),
      tag = as.character(tag_id)
    )
  )
  req <- ac_request("contactTags", method = "POST", body = body)
  data <- ac_perform(req)
  ac_parse_records(list(data$contactTag))
}

#' Remove a Tag from a Contact
#'
#' @param contact_tag_id The contact-tag association ID (from [ac_contact_tags()])
#' @return Invisibly returns `TRUE`
#' @export
ac_remove_tag <- function(contact_tag_id) {
  ac_delete_one(paste0("contactTags/", contact_tag_id))
}
