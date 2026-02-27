#' @title ActiveCampaign Contacts
#' @name ac_contacts
#' @description CRUD operations for ActiveCampaign contacts.
NULL

#' List All Contacts
#'
#' Retrieves all contacts with automatic pagination.
#'
#' @param email Filter by exact email
#' @param search Search string (matches name, email, phone)
#' @param list_id Filter by list membership
#' @param tag_id Filter by tag
#' @param updated_after Only return contacts modified after this datetime
#' @param .progress Optional progressr callback
#' @return A tibble of contacts
#' @export
#' @examples
#' \dontrun{
#' contacts <- ac_contacts()
#' contacts <- ac_contacts(email = "user@example.com")
#' }
ac_contacts <- function(email = NULL, search = NULL, list_id = NULL,
                        tag_id = NULL, updated_after = NULL,
                        .progress = NULL) {
  query <- list()
  if (!is.null(email)) query[["email"]] <- email
  if (!is.null(search)) query[["search"]] <- search
  if (!is.null(list_id)) query[["listid"]] <- as.character(list_id)
  if (!is.null(tag_id)) query[["tagid"]] <- as.character(tag_id)
  if (!is.null(updated_after)) {
    query[["filters[updated_after]"]] <- as.character(updated_after)
  }

  ac_paginate("contacts", "contacts", query = query, .progress = .progress)
}

#' Get a Single Contact
#'
#' @param id Contact ID
#' @return A single-row tibble
#' @export
ac_contact <- function(id) {
  ac_get_one(paste0("contacts/", id), "contact")
}

#' Create a Contact
#'
#' @param email Email address (required)
#' @param first_name First name
#' @param last_name Last name
#' @param phone Phone number
#' @param ... Additional fields
#' @return A single-row tibble of the created contact
#' @export
ac_create_contact <- function(email, first_name = NULL, last_name = NULL,
                              phone = NULL, ...) {
  body <- list(email = email)
  if (!is.null(first_name)) body$firstName <- first_name
  if (!is.null(last_name)) body$lastName <- last_name
  if (!is.null(phone)) body$phone <- phone
  body <- c(body, list(...))

  ac_post_one("contacts", "contact", body)
}

#' Update a Contact
#'
#' @param id Contact ID
#' @param ... Fields to update
#' @return A single-row tibble of the updated contact
#' @export
ac_update_contact <- function(id, ...) {
  body <- list(...)
  ac_put_one(paste0("contacts/", id), "contact", body)
}
