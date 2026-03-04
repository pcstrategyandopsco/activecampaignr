test_that("ac_parse_records handles empty input", {
  result <- activecampaignr:::ac_parse_records(list())
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("ac_parse_records converts records to tibble", {
  records <- list(
    list(id = "1", title = "Deal A", cdate = "2025-01-15T10:00:00-05:00"),
    list(id = "2", title = "Deal B", cdate = "2025-02-20T14:30:00-05:00")
  )

  result <- activecampaignr:::ac_parse_records(records)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_true("id" %in% names(result))
  expect_true("title" %in% names(result))
  # IDs should be character
  expect_type(result$id, "character")
})

test_that("empty_schema returns typed columns for known entities", {
  tags <- activecampaignr:::empty_schema("tags")
  expect_s3_class(tags, "tbl_df")
  expect_equal(nrow(tags), 0)
  expect_true(all(c("id", "tag", "tag_type", "description", "cdate") %in% names(tags)))
  expect_type(tags$id, "character")
  expect_s3_class(tags$cdate, "POSIXct")

  deals <- activecampaignr:::empty_schema("deals")
  expect_equal(nrow(deals), 0)
  expect_true(all(c("id", "title", "value", "currency", "status", "owner",
                     "contact", "group", "stage", "cdate", "mdate") %in% names(deals)))
  expect_type(deals$value, "double")

  contacts <- activecampaignr:::empty_schema("contacts")
  expect_equal(nrow(contacts), 0)
  expect_true(all(c("id", "email", "first_name", "last_name", "phone") %in% names(contacts)))
})

test_that("empty_schema falls back to 0x0 tibble for unknown entities", {
  result <- activecampaignr:::empty_schema("unknownEntity")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), 0)
})

test_that("ac_coerce_types keeps IDs as character", {
  df <- tibble::tibble(id = c(1, 2), owner = c(10, 20), name = c("a", "b"))
  result <- activecampaignr:::ac_coerce_types(df)
  expect_type(result$id, "character")
  expect_type(result$owner, "character")
})

test_that("ac_coerce_types converts date columns", {
  df <- tibble::tibble(
    id = "1",
    cdate = "2025-06-15 10:00:00",
    mdate = "2025-06-16 12:00:00"
  )
  result <- activecampaignr:::ac_coerce_types(df)
  expect_s3_class(result$cdate, "POSIXct")
  expect_s3_class(result$mdate, "POSIXct")
})

test_that("ac_coerce_types parses ISO 8601 offset dates correctly", {
  df <- tibble::tibble(
    id = "1",
    cdate = "2020-09-15T19:03:30-05:00",
    mdate = "2025-02-20T14:30:00-05:00"
  )
  result <- activecampaignr:::ac_coerce_types(df)
  expect_s3_class(result$cdate, "POSIXct")
  expect_s3_class(result$mdate, "POSIXct")
  # Minutes must survive parsing (proves time component not dropped)
  expect_equal(as.integer(format(result$cdate, "%M")), 3L)
  expect_equal(as.integer(format(result$mdate, "%M")), 30L)
})

test_that("ac_perform wraps HTTP errors with AC message", {
  # Simulate an httr2 HTTP error with an AC JSON response body
  local_mocked_bindings(
    req_perform = function(req) {
      # Build a fake response with AC error JSON
      resp <- httr2::response(
        status_code = 422L,
        headers = "Content-Type: application/json",
        body = charToRaw(
          '{"message":"Unprocessable Entity","errors":[{"title":"Email is invalid"}]}'
        )
      )
      # Throw an httr2-style HTTP error condition
      cnd <- rlang::error_cnd(
        message = "HTTP 422 Unprocessable Entity",
        class = c("httr2_http_422", "httr2_http_error"),
        resp = resp,
        response = resp
      )
      stop(cnd)
    },
    .package = "httr2"
  )

  fake_req <- httr2::request("https://fake.api-us1.com/api/3/contacts")

  expect_error(
    activecampaignr:::ac_perform(fake_req),
    "ActiveCampaign API error"
  )
})
