#' @title ActiveCampaign Utilities
#' @name ac_utils
#' @description Phone normalization, URL builders, and type helpers.
#' @importFrom rlang .data .env %||%
NULL

#' Standardize Phone Number
#'
#' Normalizes a phone number to E.164 international format. When the
#' \pkg{dialvalidator} package is installed, numbers are parsed and validated
#' against Google's libphonenumber metadata (240+ territories). Without it,
#' a built-in NZ/AU heuristic is used as a fallback.
#'
#' Numbers with an existing international prefix (`+`) are parsed directly.
#' Local-format numbers (starting with `0` or bare digits) are assumed to
#' be NZ by default.
#'
#' @param phone A character vector of phone numbers.
#' @param default_region ISO 3166-1 alpha-2 region code used when numbers
#'   lack a `+` prefix. Defaults to `"NZ"`.
#' @return A character vector of E.164 formatted phone strings
#'   (e.g., `"+64211234567"`), or `NA_character_` for unparseable/invalid
#'   numbers.
#' @export
#' @examples
#' ac_standardize_phone("021 123 4567")          # "+64211234567"
#' ac_standardize_phone("+64211234567")           # "+64211234567"
#' ac_standardize_phone("+61412345678")           # "+61412345678"
#' ac_standardize_phone("+12125551234")           # "+12125551234"
#' ac_standardize_phone(NA)                       # NA
ac_standardize_phone <- function(phone, default_region = "NZ") {
  if (is.null(phone)) return(NA_character_)
  if (length(phone) == 0) return(character(0))

  if (length(phone) > 1) {
    return(vapply(phone, ac_standardize_phone, character(1),
                  default_region = default_region, USE.NAMES = FALSE))
  }

  if (is.na(phone) || is.null(phone) || !nzchar(trimws(phone))) {
    return(NA_character_)
  }

  phone <- trimws(phone)

  if (has_dialvalidator()) {
    ac_standardize_phone_dv(phone, default_region)
  } else {
    ac_standardize_phone_nzau(phone)
  }
}

#' Check if dialvalidator is available
#' @noRd
has_dialvalidator <- function() {
  requireNamespace("dialvalidator", quietly = TRUE)
}

#' Standardize a phone number via dialvalidator
#'
#' @param phone A single phone string.
#' @param default_region Default region for national-format numbers.
#' @return E.164 formatted string or `NA_character_`.
#' @noRd
ac_standardize_phone_dv <- function(phone, default_region = "NZ") {
  has_plus <- startsWith(phone, "+")
  digits <- gsub("[^0-9]", "", phone)

  if (!nzchar(digits)) return(NA_character_)

  # If the input has a +, parse directly
  if (has_plus) {
    e164 <- dialvalidator::phone_format(phone, "E164")
    if (!is.na(e164)) return(e164)
    return(NA_character_)
  }

  # No + prefix: try prepending + in case it's country-code digits (e.g. "64211234567")
  candidate <- paste0("+", digits)
  e164 <- dialvalidator::phone_format(candidate, "E164")
  if (!is.na(e164) && dialvalidator::phone_valid(candidate)) {
    return(e164)
  }

  # Try as national format with default_region
  e164 <- dialvalidator::phone_format(phone, "E164", default_region = default_region)
  if (!is.na(e164)) return(e164)

  NA_character_
}

#' Built-in NZ/AU Phone Normalization (Fallback)
#'
#' Used when \pkg{dialvalidator} is not installed.
#'
#' @param phone A single phone string
#' @return E.164 formatted string or `NA_character_`
#' @keywords internal
ac_standardize_phone_nzau <- function(phone) {
  has_plus <- startsWith(phone, "+")
  digits <- gsub("[^0-9]", "", phone)

  # Too short to be valid
  if (nchar(digits) < 8) return(NA_character_)

  # Already has + prefix
  if (has_plus) return(paste0("+", digits))

  # Starts with 64 (NZ country code)
  if (startsWith(digits, "64") && nchar(digits) >= 10) {
    return(paste0("+", digits))
  }

  # Starts with 61 (AU country code)
  if (startsWith(digits, "61") && nchar(digits) >= 10) {
    return(paste0("+", digits))
  }

  # Starts with 0 (local format, assume NZ)
  if (startsWith(digits, "0")) {
    return(paste0("+64", substring(digits, 2)))
  }

  # NZ mobile without 0 (2xx format)
  if (startsWith(digits, "2") && nchar(digits) >= 8 && nchar(digits) <= 10) {
    return(paste0("+64", digits))
  }

  # AU mobile without 0 (4xx format)
  if (startsWith(digits, "4") && nchar(digits) >= 9) {
    return(paste0("+61", digits))
  }

  NA_character_
}

#' Build an ActiveCampaign Deal URL
#'
#' @param deal_id Deal ID(s)
#' @return Character vector of deal URLs
#' @keywords internal
ac_deal_url <- function(deal_id) {
  ac_check_auth()
  base <- sub("/api/3$", "", sub("/api/3/.*$", "", the$base_url))
  # Convert API URL to app URL
  app_url <- sub("\\.api-us1\\.com$", ".activehosted.com", base)
  ifelse(
    is.na(deal_id),
    NA_character_,
    paste0(app_url, "/app/deals/", deal_id)
  )
}

#' Build an ActiveCampaign Contact URL
#'
#' @param contact_id Contact ID(s)
#' @return Character vector of contact URLs
#' @keywords internal
ac_contact_url <- function(contact_id) {
  ac_check_auth()
  base <- sub("/api/3$", "", sub("/api/3/.*$", "", the$base_url))
  app_url <- sub("\\.api-us1\\.com$", ".activehosted.com", base)
  ifelse(
    is.na(contact_id),
    NA_character_,
    paste0(app_url, "/app/contacts/", contact_id)
  )
}
