#' @title ActiveCampaign Deal Pipelines and Stages
#' @name ac_deal_pipelines
#' @description Fetch pipeline and stage definitions.
NULL

#' List Deal Pipelines
#'
#' @return A tibble of pipeline definitions
#' @export
ac_deal_pipelines <- function() {
  ac_paginate("dealGroups", "dealGroups")
}

#' List Deal Stages
#'
#' @param pipeline Filter by pipeline (group) ID (optional)
#' @return A tibble of stage definitions
#' @export
ac_deal_stages <- function(pipeline = NULL) {
  query <- list()
  if (!is.null(pipeline)) {
    query[["filters[d_groupid]"]] <- as.character(pipeline)
  }
  ac_paginate("dealStages", "dealStages", query = query)
}
