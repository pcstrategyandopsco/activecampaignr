#' @title ActiveCampaign Join Helpers
#' @name ac_join
#' @description Convenience functions that fetch entities and their related
#'   data, join them, and report match diagnostics.
NULL

#' Join Deals with Custom Fields
#'
#' Fetches deals and their custom fields in wide format, then left-joins
#' them by deal ID. Prints a diagnostic summary showing match counts.
#'
#' @param ... Arguments passed to [ac_deals()] (e.g., `status`, `pipeline`,
#'   `owner`, `updated_after`)
#' @return A tibble of deals with custom field columns appended
#' @export
#' @examples
#' \dontrun{
#' deals <- ac_join_deal_fields()
#' deals <- ac_join_deal_fields(status = 1)
#' }
ac_join_deal_fields <- function(...) {
  deals <- ac_deals(...)
  n_deals <- nrow(deals)

  if (n_deals == 0) {
    cli::cli_alert_warning("No deals found")
    return(deals)
  }

  cf <- ac_deal_custom_fields_wide()
  n_cf <- nrow(cf)

  if (n_cf == 0) {
    cli::cli_alert_warning(
      "{n_deals} deal{?s} fetched but no custom field data found"
    )
    return(deals)
  }

  result <- dplyr::left_join(deals, cf, by = c("id" = "deal_id"))

  n_matched <- sum(deals$id %in% cf$deal_id)
  n_unmatched <- n_deals - n_matched

  cli::cli_alert_success(
    "{n_deals} deal{?s} joined with {ncol(cf) - 1L} custom field{?s}"
  )
  if (n_unmatched > 0) {
    cli::cli_alert_info(
      "{n_matched} matched, {n_unmatched} deal{?s} with no custom fields"
    )
  }

  result
}

#' Join Deals with Stage Names
#'
#' Fetches deals and stage definitions, then left-joins to resolve
#' stage IDs to human-readable stage names.
#'
#' @param ... Arguments passed to [ac_deals()]
#' @return A tibble of deals with `stage_title` column appended
#' @export
#' @examples
#' \dontrun{
#' deals <- ac_join_deal_stages()
#' }
ac_join_deal_stages <- function(...) {
  deals <- ac_deals(...)
  n_deals <- nrow(deals)

  if (n_deals == 0) {
    cli::cli_alert_warning("No deals found")
    return(deals)
  }

  stages <- ac_deal_stages()

  if (nrow(stages) == 0) {
    cli::cli_alert_warning(
      "{n_deals} deal{?s} fetched but no stage definitions found"
    )
    return(deals)
  }

  stage_lookup <- stages |>
    dplyr::select(stage_id = "id", stage_title = "title")

  result <- dplyr::left_join(deals, stage_lookup, by = c("stage" = "stage_id"))

  n_matched <- sum(!is.na(result$stage_title))
  n_unmatched <- n_deals - n_matched

  cli::cli_alert_success(
    "{n_deals} deal{?s} joined with stage names ({nrow(stages)} stages)"
  )
  if (n_unmatched > 0) {
    cli::cli_alert_info(
      "{n_matched} matched, {n_unmatched} deal{?s} with unknown stage"
    )
  }

  result
}

#' Join Deals with Pipeline Names
#'
#' Fetches deals and pipeline definitions, then left-joins to resolve
#' pipeline (group) IDs to human-readable pipeline names.
#'
#' @param ... Arguments passed to [ac_deals()]
#' @return A tibble of deals with `pipeline_title` column appended
#' @export
#' @examples
#' \dontrun{
#' deals <- ac_join_deal_pipelines()
#' }
ac_join_deal_pipelines <- function(...) {
  deals <- ac_deals(...)
  n_deals <- nrow(deals)

  if (n_deals == 0) {
    cli::cli_alert_warning("No deals found")
    return(deals)
  }

  pipelines <- ac_deal_pipelines()

  if (nrow(pipelines) == 0) {
    cli::cli_alert_warning(
      "{n_deals} deal{?s} fetched but no pipeline definitions found"
    )
    return(deals)
  }

  pipeline_lookup <- pipelines |>
    dplyr::select(pipeline_id = "id", pipeline_title = "title")

  result <- dplyr::left_join(
    deals, pipeline_lookup, by = c("group" = "pipeline_id")
  )

  n_matched <- sum(!is.na(result$pipeline_title))
  n_unmatched <- n_deals - n_matched

  cli::cli_alert_success(
    "{n_deals} deal{?s} joined with pipeline names ({nrow(pipelines)} pipelines)"
  )
  if (n_unmatched > 0) {
    cli::cli_alert_info(
      "{n_matched} matched, {n_unmatched} deal{?s} with unknown pipeline"
    )
  }

  result
}

#' Join Deals with Owner Names
#'
#' Fetches deals and users, then left-joins to resolve owner IDs
#' to user names and emails.
#'
#' @param ... Arguments passed to [ac_deals()]
#' @return A tibble of deals with `owner_name` and `owner_email` columns
#'   appended
#' @export
#' @examples
#' \dontrun{
#' deals <- ac_join_deal_owners()
#' }
ac_join_deal_owners <- function(...) {
  deals <- ac_deals(...)
  n_deals <- nrow(deals)

  if (n_deals == 0) {
    cli::cli_alert_warning("No deals found")
    return(deals)
  }

  users <- ac_users()

  if (nrow(users) == 0) {
    cli::cli_alert_warning(
      "{n_deals} deal{?s} fetched but no user data found"
    )
    return(deals)
  }

  # Build lookup with first + last name
  name_cols <- intersect(names(users), c("first_name", "last_name",
                                          "firstname", "lastName"))
  user_lookup <- users |>
    dplyr::mutate(
      owner_name = dplyr::if_else(
        "first_name" %in% names(users),
        paste(.data$first_name, .data$last_name),
        paste(
          .data[[name_cols[1]]] %||% "",
          .data[[name_cols[min(2, length(name_cols))]]] %||% ""
        )
      )
    ) |>
    dplyr::select(
      owner_id = "id",
      "owner_name",
      owner_email = dplyr::any_of(c("email", "username"))
    )

  result <- dplyr::left_join(deals, user_lookup, by = c("owner" = "owner_id"))

  n_matched <- sum(!is.na(result$owner_name))
  n_unmatched <- n_deals - n_matched

  cli::cli_alert_success(
    "{n_deals} deal{?s} joined with owner names ({nrow(users)} users)"
  )
  if (n_unmatched > 0) {
    cli::cli_alert_info(
      "{n_matched} matched, {n_unmatched} deal{?s} with unknown owner"
    )
  }

  result
}

#' Join Contacts with Custom Fields
#'
#' Fetches contacts and their custom fields in wide format, then left-joins
#' them by contact ID. Prints a diagnostic summary showing match counts.
#'
#' @param ... Arguments passed to [ac_contacts()] (e.g., `email`, `search`,
#'   `updated_after`)
#' @return A tibble of contacts with custom field columns appended
#' @export
#' @examples
#' \dontrun{
#' contacts <- ac_join_contact_fields()
#' contacts <- ac_join_contact_fields(email = "user@example.com")
#' }
ac_join_contact_fields <- function(...) {
  contacts <- ac_contacts(...)
  n_contacts <- nrow(contacts)

  if (n_contacts == 0) {
    cli::cli_alert_warning("No contacts found")
    return(contacts)
  }

  cf <- ac_contact_custom_fields_wide()
  n_cf <- nrow(cf)

  if (n_cf == 0) {
    cli::cli_alert_warning(
      "{n_contacts} contact{?s} fetched but no custom field data found"
    )
    return(contacts)
  }

  result <- dplyr::left_join(contacts, cf, by = c("id" = "contact_id"))

  n_matched <- sum(contacts$id %in% cf$contact_id)
  n_unmatched <- n_contacts - n_matched

  cli::cli_alert_success(
    "{n_contacts} contact{?s} joined with {ncol(cf) - 1L} custom field{?s}"
  )
  if (n_unmatched > 0) {
    cli::cli_alert_info(
      "{n_matched} matched, {n_unmatched} contact{?s} with no custom fields"
    )
  }

  result
}

#' Join Contacts with Tags
#'
#' Fetches contacts and all tags, then looks up each contact's tags
#' and appends them as a comma-separated `tags` column.
#'
#' @param ... Arguments passed to [ac_contacts()]
#' @return A tibble of contacts with a `tags` column appended
#' @export
#' @examples
#' \dontrun{
#' contacts <- ac_join_contact_tags()
#' }
ac_join_contact_tags <- function(...) {
  contacts <- ac_contacts(...)
  n_contacts <- nrow(contacts)

  if (n_contacts == 0) {
    cli::cli_alert_warning("No contacts found")
    return(contacts)
  }

  # Fetch all contact-tag associations
  all_ct <- ac_paginate("contactTags", "contactTags")

  if (nrow(all_ct) == 0) {
    cli::cli_alert_warning(
      "{n_contacts} contact{?s} fetched but no tag associations found"
    )
    contacts$tags <- NA_character_
    return(contacts)
  }

  # Fetch tag definitions for names
  tags <- ac_tags()
  tag_lookup <- tags |>
    dplyr::select(tag_id = "id", tag_name = dplyr::any_of(c("tag", "name")))

  # Find the contact column in contactTags response
  ct_contact_col <- intersect(names(all_ct), c("contact", "contact_id"))
  ct_tag_col <- intersect(names(all_ct), c("tag", "tag_id"))

  if (length(ct_contact_col) == 0 || length(ct_tag_col) == 0) {
    cli::cli_alert_warning("Unexpected contactTags response format")
    contacts$tags <- NA_character_
    return(contacts)
  }

  # Join tag names and collapse per contact
  tag_summary <- all_ct |>
    dplyr::mutate(
      .contact_id = as.character(.data[[ct_contact_col[1]]]),
      .tag_id = as.character(.data[[ct_tag_col[1]]])
    ) |>
    dplyr::left_join(tag_lookup, by = c(".tag_id" = "tag_id")) |>
    dplyr::group_by(.data$.contact_id) |>
    dplyr::summarise(
      tags = paste(stats::na.omit(.data$tag_name), collapse = ", "),
      .groups = "drop"
    )

  result <- dplyr::left_join(
    contacts, tag_summary, by = c("id" = ".contact_id")
  )

  n_matched <- sum(contacts$id %in% tag_summary$.contact_id)
  n_unmatched <- n_contacts - n_matched

  cli::cli_alert_success(
    "{n_contacts} contact{?s} joined with tags ({nrow(tags)} tags in system)"
  )
  if (n_unmatched > 0) {
    cli::cli_alert_info(
      "{n_matched} tagged, {n_unmatched} contact{?s} with no tags"
    )
  }

  result
}

#' Get Deals with All Related Data
#'
#' Fetches deals and joins custom fields, stage names, pipeline names,
#' and owner names into a single analysis-ready tibble.
#'
#' @param ... Arguments passed to [ac_deals()] (e.g., `status`, `pipeline`,
#'   `owner`, `updated_after`)
#' @return A tibble of deals with columns from custom fields, stage name,
#'   pipeline name, owner name, and owner email
#' @export
#' @examples
#' \dontrun{
#' # Everything in one call
#' deals <- ac_deals_full()
#'
#' # Won deals, fully joined
#' won <- ac_deals_full(status = 1)
#' }
ac_deals_full <- function(...) {
  deals <- ac_deals(...)
  n_deals <- nrow(deals)

  if (n_deals == 0) {
    cli::cli_alert_warning("No deals found")
    return(deals)
  }

  cli::cli_alert_info("Fetching related data for {n_deals} deal{?s}...")


  # Custom fields
  cf <- tryCatch(ac_deal_custom_fields_wide(), error = function(e) NULL)
  if (!is.null(cf) && nrow(cf) > 0) {
    deals <- dplyr::left_join(deals, cf, by = c("id" = "deal_id"))
    n_cf_cols <- ncol(cf) - 1L
    cli::cli_alert_success("Custom fields: {n_cf_cols} field{?s} joined")
  }

  # Stages
  stages <- tryCatch(ac_deal_stages(), error = function(e) NULL)
  if (!is.null(stages) && nrow(stages) > 0) {
    stage_lookup <- stages |>
      dplyr::select(stage_id = "id", stage_title = "title")
    deals <- dplyr::left_join(deals, stage_lookup,
                               by = c("stage" = "stage_id"))
    cli::cli_alert_success("Stages: {nrow(stages)} stage{?s} resolved")
  }

  # Pipelines
  pipelines <- tryCatch(ac_deal_pipelines(), error = function(e) NULL)
  if (!is.null(pipelines) && nrow(pipelines) > 0) {
    pipeline_lookup <- pipelines |>
      dplyr::select(pipeline_id = "id", pipeline_title = "title")
    deals <- dplyr::left_join(deals, pipeline_lookup,
                               by = c("group" = "pipeline_id"))
    cli::cli_alert_success(
      "Pipelines: {nrow(pipelines)} pipeline{?s} resolved"
    )
  }

  # Owners
  users <- tryCatch(ac_users(), error = function(e) NULL)
  if (!is.null(users) && nrow(users) > 0) {
    name_cols <- intersect(names(users), c("first_name", "last_name",
                                            "firstname", "lastName"))
    user_lookup <- users |>
      dplyr::mutate(
        owner_name = dplyr::if_else(
          "first_name" %in% names(users),
          paste(.data$first_name, .data$last_name),
          paste(
            .data[[name_cols[1]]] %||% "",
            .data[[name_cols[min(2, length(name_cols))]]] %||% ""
          )
        )
      ) |>
      dplyr::select(
        owner_id = "id",
        "owner_name",
        owner_email = dplyr::any_of(c("email", "username"))
      )
    deals <- dplyr::left_join(deals, user_lookup,
                               by = c("owner" = "owner_id"))
    cli::cli_alert_success("Owners: {nrow(users)} user{?s} resolved")
  }

  cli::cli_alert_success(
    "Done: {n_deals} deal{?s}, {ncol(deals)} column{?s}"
  )

  deals
}

#' Get Contacts with All Related Data
#'
#' Fetches contacts and joins custom fields and tags into a single
#' analysis-ready tibble.
#'
#' @param ... Arguments passed to [ac_contacts()] (e.g., `email`, `search`,
#'   `updated_after`)
#' @return A tibble of contacts with custom field columns and a `tags` column
#' @export
#' @examples
#' \dontrun{
#' contacts <- ac_contacts_full()
#' }
ac_contacts_full <- function(...) {
  contacts <- ac_contacts(...)
  n_contacts <- nrow(contacts)

  if (n_contacts == 0) {
    cli::cli_alert_warning("No contacts found")
    return(contacts)
  }

  cli::cli_alert_info(
    "Fetching related data for {n_contacts} contact{?s}..."
  )

  # Custom fields
  cf <- tryCatch(ac_contact_custom_fields_wide(), error = function(e) NULL)
  if (!is.null(cf) && nrow(cf) > 0) {
    contacts <- dplyr::left_join(contacts, cf,
                                  by = c("id" = "contact_id"))
    n_cf_cols <- ncol(cf) - 1L
    cli::cli_alert_success("Custom fields: {n_cf_cols} field{?s} joined")
  }

  # Tags
  all_ct <- tryCatch(
    ac_paginate("contactTags", "contactTags"),
    error = function(e) NULL
  )
  if (!is.null(all_ct) && nrow(all_ct) > 0) {
    tags <- tryCatch(ac_tags(), error = function(e) NULL)
    if (!is.null(tags) && nrow(tags) > 0) {
      tag_lookup <- tags |>
        dplyr::select(tag_id = "id",
                      tag_name = dplyr::any_of(c("tag", "name")))

      ct_contact_col <- intersect(names(all_ct), c("contact", "contact_id"))
      ct_tag_col <- intersect(names(all_ct), c("tag", "tag_id"))

      if (length(ct_contact_col) > 0 && length(ct_tag_col) > 0) {
        tag_summary <- all_ct |>
          dplyr::mutate(
            .contact_id = as.character(.data[[ct_contact_col[1]]]),
            .tag_id = as.character(.data[[ct_tag_col[1]]])
          ) |>
          dplyr::left_join(tag_lookup, by = c(".tag_id" = "tag_id")) |>
          dplyr::group_by(.data$.contact_id) |>
          dplyr::summarise(
            tags = paste(stats::na.omit(.data$tag_name), collapse = ", "),
            .groups = "drop"
          )

        contacts <- dplyr::left_join(
          contacts, tag_summary, by = c("id" = ".contact_id")
        )
        cli::cli_alert_success(
          "Tags: {nrow(tags)} tag{?s} resolved"
        )
      }
    }
  }

  cli::cli_alert_success(
    "Done: {n_contacts} contact{?s}, {ncol(contacts)} column{?s}"
  )

  contacts
}
