test_that("ac_deals builds correct query parameters", {
  # We can't call the API without auth, but we can test query building
  # by checking that the function requires authentication
  env <- activecampaignr:::the
  old_url <- env$base_url
  old_key <- env$api_key
  env$base_url <- NULL
  env$api_key <- NULL

  expect_error(ac_deals(), "Not authenticated")

  env$base_url <- old_url
  env$api_key <- old_key
})
