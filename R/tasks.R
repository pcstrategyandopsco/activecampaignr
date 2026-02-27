#' @title ActiveCampaign Tasks
#' @name ac_tasks
#' @description CRUD operations for ActiveCampaign tasks.
NULL

#' List All Tasks
#'
#' @param .progress Optional progressr callback
#' @return A tibble of tasks
#' @export
ac_tasks <- function(.progress = NULL) {
  ac_paginate("dealTasks", "dealTasks", .progress = .progress)
}

#' Create a Task
#'
#' @param title Task title
#' @param deal_id Deal ID to associate with
#' @param due_date Due date (character `"YYYY-MM-DD"` or Date)
#' @param type Task type ID
#' @param assignee User ID to assign to
#' @param note Task note/body
#' @param ... Additional fields
#' @return A single-row tibble
#' @export
ac_create_task <- function(title, deal_id = NULL, due_date = NULL,
                           type = NULL, assignee = NULL, note = NULL, ...) {
  body <- list(title = title)
  if (!is.null(deal_id)) body$relid <- as.character(deal_id)
  if (!is.null(due_date)) body$duedate <- as.character(due_date)
  if (!is.null(type)) body$dealTasktype <- as.character(type)
  if (!is.null(assignee)) body$assignee <- as.character(assignee)
  if (!is.null(note)) body$note <- note
  body <- c(body, list(...))
  ac_post_one("dealTasks", "dealTask", body)
}

#' Update a Task
#'
#' @param id Task ID
#' @param ... Fields to update
#' @return A single-row tibble
#' @export
ac_update_task <- function(id, ...) {
  ac_put_one(paste0("dealTasks/", id), "dealTask", list(...))
}
