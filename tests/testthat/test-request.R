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
