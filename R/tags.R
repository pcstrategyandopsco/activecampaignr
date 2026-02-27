#' @title ActiveCampaign Tags
#' @name ac_tags
#' @description Manage tags.
NULL

#' List All Tags
#'
#' @param search Search string
#' @return A tibble of tags
#' @export
ac_tags <- function(search = NULL) {
  query <- list()
  if (!is.null(search)) query[["search"]] <- search
  ac_paginate("tags", "tags", query = query)
}

#' Create a Tag
#'
#' @param name Tag name
#' @param type Tag type: `"contact"` or `"deal"`
#' @param description Tag description
#' @return A single-row tibble
#' @export
ac_create_tag <- function(name, type = "contact", description = NULL) {
  body <- list(tag = name, tagType = type)
  if (!is.null(description)) body$description <- description
  ac_post_one("tags", "tag", body)
}
