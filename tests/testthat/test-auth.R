test_that("ac_check_auth errors when not authenticated", {
  # Reset auth state
  env <- activecampaignr:::the
  old_url <- env$base_url
  old_key <- env$api_key
  env$base_url <- NULL
  env$api_key <- NULL

  expect_error(activecampaignr:::ac_check_auth(), "Not authenticated")

  # Restore

  env$base_url <- old_url
  env$api_key <- old_key
})

test_that("ac_auth validates inputs", {
  # Bad URL should fail during the test request
  expect_error(
    ac_auth("https://nonexistent-test-12345.api-us1.com", "fake-key"),
    "Authentication failed"
  )
})

test_that("ac_auth_from_env errors without credentials", {
  withr::with_envvar(
    c(ACTIVECAMPAIGN_URL = NA, ACTIVECAMPAIGN_API_KEY = NA),
    {
      expect_error(ac_auth_from_env(), "credentials not found")
    }
  )
})

test_that("ac_get_tz returns configured timezone", {
  env <- activecampaignr:::the
  old_tz <- env$timezone
  env$timezone <- "Pacific/Auckland"
  expect_equal(activecampaignr:::ac_get_tz(), "Pacific/Auckland")
  env$timezone <- old_tz
})
