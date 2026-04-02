# ---- Helpers ----------------------------------------------------------------

setup_fake_auth <- function() {
  env <- activecampaignr:::the
  env$base_url <- "https://fake.api-us1.com"
  env$api_key <- "fake-key"
  env$timezone <- "UTC"
  withr::defer({
    env$base_url <- NULL
    env$api_key <- NULL
  }, envir = parent.frame())
}


# ---- ac_deal_custom_field_values: multi-deal filtering ----------------------

test_that("ac_deal_custom_field_values queries each deal_id individually", {
  setup_fake_auth()

  captured_queries <- list()

  local_mocked_bindings(
    ac_paginate = function(endpoint, entity_key, query = list(), ...) {
      captured_queries[[length(captured_queries) + 1L]] <<- query
      deal_id_val <- query[["filters[dealId]"]]
      tibble::tibble(
        id = paste0("row-", deal_id_val),
        deal_id = deal_id_val,
        custom_field_meta_id = "1",
        custom_field_datum_value = paste0("val-", deal_id_val)
      )
    },
    .package = "activecampaignr"
  )

  expect_warning(
    result <- ac_deal_custom_field_values(deal_id = c("4005", "4008")),
    "individually"
  )

  # Two separate API calls, one per deal_id
  expect_equal(length(captured_queries), 2)
  expect_equal(captured_queries[[1]][["filters[dealId]"]], "4005")
  expect_equal(captured_queries[[2]][["filters[dealId]"]], "4008")

  # Combined result has both deals
  expect_equal(nrow(result), 2)
  expect_true(all(c("4005", "4008") %in% result$deal_id))
})

test_that("ac_deal_custom_field_values deduplicates by id", {
  setup_fake_auth()

  local_mocked_bindings(
    ac_paginate = function(endpoint, entity_key, query = list(), ...) {
      deal_id_val <- query[["filters[dealId]"]]
      tibble::tibble(
        id = c(paste0("unique-", deal_id_val), "dup"),
        deal_id = c(deal_id_val, "shared"),
        custom_field_meta_id = "1",
        custom_field_datum_value = "x"
      )
    },
    .package = "activecampaignr"
  )

  suppressWarnings(
    result <- ac_deal_custom_field_values(deal_id = c("100", "200"))
  )

  # 2 unique + 1 shared (deduplicated) = 3
  expect_equal(nrow(result), 3)
  expect_equal(sum(result$id == "dup"), 1)
})

test_that("ac_deal_custom_field_values with single deal_id does not warn", {
  setup_fake_auth()

  captured_queries <- list()

  local_mocked_bindings(
    ac_paginate = function(endpoint, entity_key, query = list(), ...) {
      captured_queries[[length(captured_queries) + 1L]] <<- query
      tibble::tibble(
        id = "1", deal_id = "99",
        custom_field_meta_id = "1", custom_field_datum_value = "v"
      )
    },
    .package = "activecampaignr"
  )

  expect_no_warning(
    result <- ac_deal_custom_field_values(deal_id = "99")
  )

  expect_equal(length(captured_queries), 1)
  expect_equal(captured_queries[[1]][["filters[dealId]"]], "99")
  expect_equal(nrow(result), 1)
})

test_that("ac_deal_custom_field_values with NULL deal_id fetches all", {
  setup_fake_auth()

  captured_queries <- list()

  local_mocked_bindings(
    ac_paginate = function(endpoint, entity_key, query = list(), ...) {
      captured_queries[[length(captured_queries) + 1L]] <<- query
      tibble::tibble(
        id = "1", deal_id = "1",
        custom_field_meta_id = "1", custom_field_datum_value = "v"
      )
    },
    .package = "activecampaignr"
  )

  result <- ac_deal_custom_field_values()

  # Single call with no filter
  expect_equal(length(captured_queries), 1)
  expect_null(captured_queries[[1]][["filters[dealId]"]])
})
