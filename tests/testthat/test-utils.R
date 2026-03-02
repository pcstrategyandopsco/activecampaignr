# --- validate_email tests ---

test_that("validate_email accepts valid emails", {
  expect_equal(validate_email("user@example.com"), "user@example.com")
  expect_equal(validate_email("user+tag@example.com"), "user+tag@example.com")
  expect_equal(validate_email("user@sub.domain.co.nz"), "user@sub.domain.co.nz")
  expect_equal(validate_email("a@b.museum"), "a@b.museum")
})

test_that("validate_email trims whitespace silently", {
  expect_equal(validate_email("  user@example.com  "), "user@example.com")
  expect_equal(validate_email("\tuser@example.com\n"), "user@example.com")
})

test_that("validate_email rejects NULL, NA, empty", {
  expect_error(validate_email(NULL), "non-NA string")
  expect_error(validate_email(NA), "non-NA string")
  expect_error(validate_email(""), "must not be empty")
  expect_error(validate_email("   "), "must not be empty")
})

test_that("validate_email rejects missing or multiple @", {
  expect_error(validate_email("noatsign"), "exactly one")
  expect_error(validate_email("two@@signs.com"), "exactly one")
  expect_error(validate_email("a@b@c.com"), "exactly one")
})

test_that("validate_email rejects whitespace in address", {
  expect_error(validate_email("user @example.com"), "whitespace")
  expect_error(validate_email("user@ example.com"), "whitespace")
})

test_that("validate_email rejects empty local or domain", {
  expect_error(validate_email("@example.com"), "empty local part")
  expect_error(validate_email("user@"), "empty domain")
})

test_that("validate_email rejects domain without dot", {
  expect_error(validate_email("user@localhost"), "domain must contain a dot")
})

test_that("validate_email rejects invalid dots in local part", {
  expect_error(validate_email(".user@example.com"), "invalid dots")
  expect_error(validate_email("user.@example.com"), "invalid dots")
  expect_error(validate_email("us..er@example.com"), "invalid dots")
})

test_that("validate_email rejects over-length parts", {
  long_local <- paste0(paste(rep("a", 65), collapse = ""), "@example.com")
  expect_error(validate_email(long_local), "exceeds 64")

  long_domain <- paste0("u@", paste(rep("a", 254), collapse = ""), ".com")
  expect_error(validate_email(long_domain), "exceeds 253")
})

# --- ac_standardize_phone tests ---

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
