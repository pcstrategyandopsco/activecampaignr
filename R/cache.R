#' @title ActiveCampaign Cache Manager
#' @name ac_cache
#' @description RDS-based caching with TTL and incremental merge support.
NULL

#' Cache-or-Fetch Wrapper
#'
#' Returns cached data if fresh (within TTL), otherwise calls `fn` and
#' caches the result.
#'
#' @param key Cache key (used as filename, e.g., `"deals"`)
#' @param fn A function that returns a tibble (called if cache is stale)
#' @param ttl_minutes Time-to-live in minutes (default: 10)
#' @param force If `TRUE`, bypasses the cache
#' @return The cached or freshly fetched tibble
#' @export
#' @keywords internal
ac_cache <- function(key, fn, ttl_minutes = 10, force = FALSE) {
  ac_check_auth()
  path <- ac_cache_file(key)

  if (!force && file.exists(path)) {
    age_min <- as.numeric(difftime(Sys.time(), file.info(path)$mtime,
                                   units = "mins"))
    if (age_min < ttl_minutes) {
      cli::cli_alert_info("{key}: using cache ({round(age_min, 1)} min old)")
      return(readRDS(path))
    }
  }

  result <- fn()

  if (tibble::is_tibble(result) || is.data.frame(result)) {
    saveRDS(result, path)
  }

  result
}

#' Get the Cache File Path for a Key
#'
#' @param key Cache key
#' @return File path
#' @keywords internal
ac_cache_file <- function(key) {
  ac_check_auth()
  file.path(the$cache_dir, paste0(key, ".rds"))
}

#' Get or Set the Cache Directory
#'
#' @param path New cache directory path (optional). If `NULL`, returns
#'   the current path.
#' @return The cache directory path (invisibly if setting)
#' @export
ac_cache_path <- function(path = NULL) {
  if (!is.null(path)) {
    the$cache_dir <- path.expand(path)
    if (!dir.exists(the$cache_dir)) {
      dir.create(the$cache_dir, recursive = TRUE)
    }
    return(invisible(the$cache_dir))
  }
  the$cache_dir %||% path.expand("~/.activecampaignr/cache")
}

#' Clear the Cache
#'
#' Removes all cached RDS files, or a specific key.
#'
#' @param key Optional specific cache key to clear. If `NULL`, clears all.
#' @return Invisibly returns the number of files removed
#' @export
ac_cache_clear <- function(key = NULL) {
  dir <- ac_cache_path()
  if (!dir.exists(dir)) return(invisible(0L))

  if (!is.null(key)) {
    path <- file.path(dir, paste0(key, ".rds"))
    if (file.exists(path)) {
      file.remove(path)
      cli::cli_alert_info("Removed cache for {.val {key}}")
      return(invisible(1L))
    }
    return(invisible(0L))
  }

  files <- list.files(dir, pattern = "\\.rds$", full.names = TRUE)
  if (length(files) > 0) {
    file.remove(files)
    cli::cli_alert_info("Removed {length(files)} cached file{?s}")
  }
  invisible(length(files))
}

#' Show Cache Status
#'
#' Lists all cached entities with their ages and row counts.
#'
#' @return A tibble with columns: key, rows, age_minutes, size_kb, path
#' @export
ac_cache_status <- function() {
  dir <- ac_cache_path()
  if (!dir.exists(dir)) {
    cli::cli_alert_info("No cache directory found")
    return(tibble::tibble(
      key = character(), rows = integer(), age_minutes = double(),
      size_kb = double(), path = character()
    ))
  }

  files <- list.files(dir, pattern = "\\.rds$", full.names = TRUE)
  if (length(files) == 0) {
    cli::cli_alert_info("Cache is empty")
    return(tibble::tibble(
      key = character(), rows = integer(), age_minutes = double(),
      size_kb = double(), path = character()
    ))
  }

  purrr::map_dfr(files, function(f) {
    info <- file.info(f)
    data <- tryCatch(readRDS(f), error = function(e) NULL)
    rows <- if (is.data.frame(data)) nrow(data) else NA_integer_

    tibble::tibble(
      key = tools::file_path_sans_ext(basename(f)),
      rows = rows,
      age_minutes = round(as.numeric(
        difftime(Sys.time(), info$mtime, units = "mins")
      ), 1),
      size_kb = round(info$size / 1024, 1),
      path = f
    )
  })
}

#' Merge Cached and New Records
#'
#' Replaces old versions of updated records (by ID) and appends new ones.
#' Used by incremental sync functions.
#'
#' @param stored Existing cached tibble
#' @param new_data Freshly fetched tibble
#' @param id_col Column name used as the unique identifier (default: `"id"`)
#' @return Merged tibble
#' @keywords internal
ac_merge_records <- function(stored, new_data, id_col = "id") {
  if (nrow(new_data) == 0) return(stored)
  if (nrow(stored) == 0) return(new_data)

  updated_ids <- new_data[[id_col]]
  kept <- dplyr::filter(stored, !.data[[id_col]] %in% updated_ids)
  merged <- dplyr::bind_rows(kept, new_data)
  merged <- dplyr::distinct(merged, .data[[id_col]], .keep_all = TRUE)

  cli::cli_alert_info(
    "Merged: {nrow(kept)} kept + {nrow(new_data)} updated = {nrow(merged)} total"
  )
  merged
}
