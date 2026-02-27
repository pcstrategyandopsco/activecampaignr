#' @title ActiveCampaign Automations
#' @name ac_automations
#' @description Fetch and trigger automations.
NULL

#' List All Automations
#'
#' @return A tibble of automations
#' @export
ac_automations <- function() {
  ac_paginate("automations", "automations")
}

#' Trigger an Automation for a Contact
#'
#' Adds a contact to an automation.
#'
#' @param automation_id Automation ID
#' @param contact_id Contact ID
#' @return A single-row tibble of the contact-automation association
#' @export
ac_trigger_automation <- function(automation_id, contact_id) {
  body <- list(
    contactAutomation = list(
      contact = as.character(contact_id),
      automation = as.character(automation_id)
    )
  )
  req <- ac_request("contactAutomations", method = "POST", body = body)
  data <- ac_perform(req)
  ac_parse_records(list(data$contactAutomation %||% list()))
}
