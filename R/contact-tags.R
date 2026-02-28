#' @title ActiveCampaign Contact Tags
#' @name ac_contact_tags
#' @description Manage tags on contacts.
NULL

#' List Tags on a Contact
#'
#' Returns a tibble with tag names resolved. The raw API only returns tag IDs;
#' this function automatically joins against [ac_tags()] to include tag names.
#'
#' @param contact_id Contact ID
#' @return A tibble with columns `contact_id`, `tag_id`, `tag_name`, and
#'   `contact_tag_id` (the association ID, used by [ac_remove_tag()])
#' @export
ac_contact_tags <- function(contact_id) {
  raw <- ac_paginate(
    paste0("contacts/", contact_id, "/contactTags"),
    "contactTags"
  )

  if (nrow(raw) == 0L) {
    return(tibble::tibble(
      contact_id = character(),
      tag_id = character(),
      tag_name = character(),
      contact_tag_id = character()
    ))
  }

  tags <- ac_tags()

  result <- raw |>
    dplyr::left_join(
      tags |> dplyr::select("id", tag_name = "tag"),
      by = c("tag" = "id")
    ) |>
    dplyr::transmute(
      contact_id = .data$contact,
      tag_id = .data$tag,
      tag_name = .data$tag_name,
      contact_tag_id = .data$id
    )

  n_resolved <- sum(!is.na(result$tag_name))
  n_total <- nrow(result)
  if (n_resolved < n_total) {
    cli::cli_warn(
      "{n_total - n_resolved} of {n_total} tag{?s} could not be resolved to a name."
    )
  }

  result
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
