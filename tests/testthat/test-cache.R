test_that("ac_merge_records merges correctly", {
  stored <- tibble::tibble(id = c("1", "2", "3"), name = c("A", "B", "C"))
  new_data <- tibble::tibble(id = c("2", "4"), name = c("B-updated", "D"))

  result <- activecampaignr:::ac_merge_records(stored, new_data)
  expect_equal(nrow(result), 4)
  expect_equal(result$name[result$id == "2"], "B-updated")
  expect_true("4" %in% result$id)
})

test_that("ac_merge_records handles empty stored", {
  stored <- tibble::tibble(id = character(), name = character())
  new_data <- tibble::tibble(id = c("1", "2"), name = c("A", "B"))

  result <- activecampaignr:::ac_merge_records(stored, new_data)
  expect_equal(nrow(result), 2)
})

test_that("ac_merge_records handles empty new data", {
  stored <- tibble::tibble(id = c("1", "2"), name = c("A", "B"))
  new_data <- tibble::tibble(id = character(), name = character())

  result <- activecampaignr:::ac_merge_records(stored, new_data)
  expect_equal(nrow(result), 2)
})

test_that("ac_cache_status returns tibble", {
  env <- activecampaignr:::the
  old_dir <- env$cache_dir
  env$cache_dir <- tempdir()

  result <- ac_cache_status()
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("key", "rows", "age_minutes", "size_kb") %in% names(result)))

  env$cache_dir <- old_dir
})

test_that("ac_cache_clear works on empty directory", {
  env <- activecampaignr:::the
  old_dir <- env$cache_dir
  tmp <- tempfile()
  dir.create(tmp)
  env$cache_dir <- tmp

  expect_equal(ac_cache_clear(), 0L)

  env$cache_dir <- old_dir
  unlink(tmp, recursive = TRUE)
})

test_that("ac_cache stores and retrieves data", {
  env <- activecampaignr:::the
  old_url <- env$base_url
  old_key <- env$api_key
  old_dir <- env$cache_dir

  env$base_url <- "https://test.api-us1.com"
  env$api_key <- "fake-key"
  tmp <- tempfile()
  dir.create(tmp)
  env$cache_dir <- tmp

  test_data <- tibble::tibble(x = 1:3, y = c("a", "b", "c"))
  result <- activecampaignr:::ac_cache("test_key", function() test_data, ttl_minutes = 60)
  expect_equal(result, test_data)

  # Should hit cache on second call
  result2 <- activecampaignr:::ac_cache("test_key", function() stop("should not call"), ttl_minutes = 60)
  expect_equal(result2, test_data)

  env$base_url <- old_url
  env$api_key <- old_key
  env$cache_dir <- old_dir
  unlink(tmp, recursive = TRUE)
})
