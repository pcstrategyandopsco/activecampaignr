test_that("ac_standardize_phone handles NZ numbers", {
  expect_equal(ac_standardize_phone("021 123 4567"), "+64211234567")
  expect_equal(ac_standardize_phone("0211234567"), "+64211234567")
  expect_equal(ac_standardize_phone("+64211234567"), "+64211234567")
  expect_equal(ac_standardize_phone("64211234567"), "+64211234567")
})

test_that("ac_standardize_phone handles AU numbers", {
  expect_equal(ac_standardize_phone("+61412345678"), "+61412345678")
  expect_equal(ac_standardize_phone("61412345678"), "+61412345678")
})

test_that("ac_standardize_phone handles NZ mobile without leading 0", {
  expect_equal(ac_standardize_phone("211234567"), "+64211234567")
  expect_equal(ac_standardize_phone("2712345678"), "+642712345678")
})

test_that("ac_standardize_phone handles NA and empty", {
  expect_true(is.na(ac_standardize_phone(NA)))
  expect_true(is.na(ac_standardize_phone("")))
  expect_true(is.na(ac_standardize_phone("   ")))
  expect_true(is.na(ac_standardize_phone(NULL)))
})

test_that("ac_standardize_phone handles too-short numbers", {
  expect_true(is.na(ac_standardize_phone("12345")))
  expect_true(is.na(ac_standardize_phone("1234567")))
})

test_that("ac_standardize_phone strips non-digit characters", {
  expect_equal(ac_standardize_phone("021-123-4567"), "+64211234567")
  expect_equal(ac_standardize_phone("(021) 123 4567"), "+64211234567")
  expect_equal(ac_standardize_phone("+64 21 123 4567"), "+64211234567")
})

test_that("ac_standardize_phone vectorizes", {
  phones <- c("0211234567", NA, "+61412345678", "")
  result <- ac_standardize_phone(phones)
  expect_equal(length(result), 4)
  expect_equal(result[1], "+64211234567")
  expect_true(is.na(result[2]))
  expect_equal(result[3], "+61412345678")
  expect_true(is.na(result[4]))
})

test_that("ac_standardize_phone handles international numbers", {
  expect_equal(ac_standardize_phone("+12125551234"), "+12125551234")
  expect_equal(ac_standardize_phone("+442071234567"), "+442071234567")
  expect_equal(ac_standardize_phone("+81312345678"), "+81312345678")
})

test_that("ac_standardize_phone respects default_region", {
  skip_if_not_installed("dialvalidator")
  # AU local number with AU default
  expect_equal(ac_standardize_phone("0412345678", default_region = "AU"), "+61412345678")
})

test_that("ac_standardize_phone returns character(0) for empty vector", {
  expect_equal(ac_standardize_phone(character(0)), character(0))
})
