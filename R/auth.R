#' @title ActiveCampaign Authentication
#' @name ac_auth
#' @description Set up authentication for the ActiveCampaign API.
NULL

# Internal environment for storing auth state
the <- new.env(parent = emptyenv())
the$base_url <- NULL
the$api_key <- NULL
the$timezone <- "UTC"
the$cache_dir <- NULL

#' Authenticate with ActiveCampaign
#'
#' Stores credentials for subsequent API calls. Validates the connection
#' with a test request to the API.
#'
#' @param url Your ActiveCampaign API URL (e.g., `"https://yourname.api-us1.com"`)
#' @param api_key Your ActiveCampaign API key
#' @param timezone Timezone for datetime conversion (default: `"UTC"`)
#' @param cache_dir Directory for RDS cache files (default: `"~/.activecampaignr/cache"`)
#' @return Invisibly returns `TRUE` on success
#' @export
#' @examples
#' \dontrun{
#' ac_auth(
#'   url = "https://yourname.api-us1.com",
#'   api_key = "your-api-key-here"
#' )
#' }
ac_auth <- function(url, api_key, timezone = "UTC",
                    cache_dir = "~/.activecampaignr/cache") {
  url <- sub("/+$", "", url)

  the$base_url <- url
  the$api_key <- api_key
  the$timezone <- timezone
  the$cache_dir <- path.expand(cache_dir)

  if (!dir.exists(the$cache_dir)) {
    dir.create(the$cache_dir, recursive = TRUE)
  }

  # Validate with a test request
  tryCatch(
    {
      req <- ac_request("users/me")
      resp <- httr2::req_perform(req)
      cli::cli_alert_success("Authenticated with ActiveCampaign at {.url {url}}")
    },
    error = function(e) {
      the$base_url <- NULL
      the$api_key <- NULL
      cli::cli_abort(c(
        "Authentication failed",
        "x" = "Could not connect to {.url {url}}",
        "i" = "Check your URL and API key",
        "!" = conditionMessage(e)
      ))
    }
  )

  invisible(TRUE)
}

#' Authenticate from Environment Variables
#'
#' Reads `ACTIVECAMPAIGN_URL` and `ACTIVECAMPAIGN_API_KEY` from the
#' environment. Optionally reads from a `config.yml` file.
#'
#' @param config_file Path to a `config.yml` file (optional). If provided
#'   and the `config` package is installed, reads credentials from it.
#' @param timezone Timezone for datetime conversion (default: `"UTC"`)
#' @param cache_dir Directory for RDS cache files
#' @return Invisibly returns `TRUE` on success
#' @export
ac_auth_from_env <- function(config_file = NULL, timezone = "UTC",
                             cache_dir = "~/.activecampaignr/cache") {
  url <- NULL
  api_key <- NULL

  # Try config.yml first if provided

  if (!is.null(config_file) && file.exists(config_file)) {
    if (!requireNamespace("config", quietly = TRUE)) {
      cli::cli_warn("Package {.pkg config} is needed to read config files")
    } else {
      cfg <- config::get(file = config_file)
      url <- cfg$activecampaign$url %||% cfg$ACTIVECAMPAIGN_URL
      api_key <- cfg$activecampaign$api_key %||% cfg$ACTIVECAMPAIGN_API_KEY
    }
  }

  # Fall back to environment variables

  url <- url %||% Sys.getenv("ACTIVECAMPAIGN_URL", unset = NA)
  api_key <- api_key %||% Sys.getenv("ACTIVECAMPAIGN_API_KEY", unset = NA)

  if (is.na(url) || is.na(api_key)) {
    cli::cli_abort(c(
      "ActiveCampaign credentials not found",
      "i" = "Set {.envvar ACTIVECAMPAIGN_URL} and {.envvar ACTIVECAMPAIGN_API_KEY}",
      "i" = "Or pass a {.file config.yml} path"
    ))
  }

  ac_auth(url = url, api_key = api_key, timezone = timezone,
          cache_dir = cache_dir)
}

#' Check Authentication Status
#'
#' @return Invisibly returns `TRUE` if authenticated
#' @keywords internal
ac_check_auth <- function() {
  if (is.null(the$base_url) || is.null(the$api_key)) {
    cli::cli_abort(c(
      "Not authenticated",
      "i" = "Run {.fn ac_auth} or {.fn ac_auth_from_env} first"
    ))
  }
  invisible(TRUE)
}

#' Get the configured timezone
#' @keywords internal
ac_get_tz <- function() {
  the$timezone %||% "UTC"
}
