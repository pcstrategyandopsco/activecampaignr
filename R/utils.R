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

#' Validate an Email Address
#'
#' Performs local (no network) validation of an email address. Trims
#' whitespace, checks structure (RFC 5321/5322 basics), and aborts with
#' a clear error if invalid.
#'
#' @param email A single email string.
#' @return The trimmed email string (invisibly). Aborts on invalid input.
#' @keywords internal
validate_email <- function(email) {
  if (is.null(email) || length(email) != 1 || is.na(email)) {
    cli::cli_abort("{.arg email} must be a non-NA string.")
  }

  email <- trimws(email)

  if (!nzchar(email)) {
    cli::cli_abort("{.arg email} must not be empty.")
  }

  if (grepl("\\s", email)) {
    cli::cli_abort("{.arg email} must not contain whitespace: {.val {email}}")
  }

  at_count <- nchar(gsub("[^@]", "", email))
  if (at_count != 1) {
    cli::cli_abort("{.arg email} must contain exactly one {.code @}: {.val {email}}")
  }

  at_pos <- regexpr("@", email, fixed = TRUE)
  local <- substr(email, 1, at_pos - 1)
  domain <- substr(email, at_pos + 1, nchar(email))

  if (!nzchar(local)) {
    cli::cli_abort("{.arg email} has an empty local part: {.val {email}}")
  }
  if (!nzchar(domain)) {
    cli::cli_abort("{.arg email} has an empty domain: {.val {email}}")
  }

  if (!grepl(".", domain, fixed = TRUE)) {
    cli::cli_abort("{.arg email} domain must contain a dot: {.val {email}}")
  }

  # RFC 5322: no leading, trailing, or consecutive dots in local part
  if (grepl("^\\.|\\.$|\\.\\.", local)) {
    cli::cli_abort("{.arg email} local part has invalid dots: {.val {email}}")
  }

  # RFC 5321 length limits

  if (nchar(local) > 64) {
    cli::cli_abort("{.arg email} local part exceeds 64 characters: {.val {email}}")
  }
  if (nchar(domain) > 253) {
    cli::cli_abort("{.arg email} domain exceeds 253 characters: {.val {email}}")
  }

  invisible(email)
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

#' Build a Field Registry from Field Definitions
#'
#' Creates a registry storing field ID and type for each custom field,
#' keyed by the cleaned field label.
#'
#' @param fields A tibble from `ac_deal_custom_fields()` or
#'   `ac_contact_custom_fields()`. Deal fields have `field_label` and
#'   `field_type`; contact fields have `title` and `type`.
#' @param entity Label for the registry (e.g., `"Deal"`, `"Contact"`).
#' @return An `ac_field_registry` object (named list of
#'   `list(id, type)` entries).
#' @keywords internal
ac_build_field_registry <- function(fields, entity) {
  if (nrow(fields) == 0) {
    registry <- stats::setNames(list(), character())
    class(registry) <- "ac_field_registry"
    attr(registry, "entity") <- entity
    attr(registry, "fetched_at") <- Sys.time()
    return(registry)
  }

  ids <- as.character(fields$id)

  # Deal fields: field_label / field_type; Contact fields: title / type
  label_col <- intersect(names(fields), c("field_label", "title"))
  type_col <- intersect(names(fields), c("field_type", "type"))
  if (length(label_col) == 0) {
    cli::cli_abort("Cannot find a label column in field definitions.")
  }

  labels <- fields[[label_col[1]]]
  types <- if (length(type_col) > 0) as.character(fields[[type_col[1]]]) else rep(NA_character_, length(ids))
  names_clean <- janitor::make_clean_names(labels)

  # Detect duplicate names and disambiguate with field ID suffix
  dupes <- duplicated(names_clean) | duplicated(names_clean, fromLast = TRUE)
  if (any(dupes)) {
    dupe_names <- unique(names_clean[dupes])
    cli::cli_warn(c(
      "Duplicate field names after cleaning: {.val {dupe_names}}",
      "i" = "Appending field IDs to disambiguate."
    ))
    names_clean[dupes] <- paste0(names_clean[dupes], "_", ids[dupes])
  }

  registry <- stats::setNames(
    Map(function(id, type) list(id = id, type = type), ids, types),
    names_clean
  )
  class(registry) <- "ac_field_registry"
  attr(registry, "entity") <- entity
  attr(registry, "fetched_at") <- Sys.time()

  registry
}

#' Access a Field ID by Name
#'
#' The `$` operator on an `ac_field_registry` returns the field ID
#' (character) for the given name, keeping `cdf$source` ergonomic.
#' Use [ac_field_id()] for validated lookups with type checking.
#'
#' @param x An `ac_field_registry` object
#' @param name Field name
#' @return Field ID as a character string, or `NULL` if not found
#' @export
`$.ac_field_registry` <- function(x, name) {
  entry <- .subset2(x, name)
  if (is.null(entry)) return(NULL)
  entry$id
}

#' Print Method for Field Registry
#'
#' @param x An `ac_field_registry` object
#' @param ... Ignored
#' @export
print.ac_field_registry <- function(x, ...) {
  entity <- attr(x, "entity")
  age <- round(difftime(Sys.time(), attr(x, "fetched_at"), units = "mins"), 1)
  cli::cli_h3("{entity} custom fields ({length(x)} fields, {age} min old)")
  for (nm in names(x)) {
    entry <- .subset2(x, nm)
    cli::cli_li("{.field {nm}}: {.val {entry$id}} ({entry$type})")
  }
  invisible(x)
}

#' Look Up a Field ID with Validation
#'
#' Extracts a field ID from a registry, raising an informative error if
#' the field name is not found (e.g., after a rename in AC admin).
#' Optionally validates that `value` is compatible with the field's type
#' (`"number"`/`"currency"` must be numeric, `"date"`/`"datetime"` must
#' parse as a date).
#'
#' For simple lookups without validation, you can use `cdf$field_name`
#' directly (returns the ID or `NULL` if not found).
#'
#' @param registry An `ac_field_registry` from [ac_deal_field_ids()] or
#'   [ac_contact_field_ids()]
#' @param field_name The clean field name to look up
#' @param value Optional value to validate against the field type
#' @return The field ID as a character string
#' @seealso [ac_deal_field_ids()] and [ac_contact_field_ids()] to build
#'   registries, [ac_deal_custom_fields()] and
#'   [ac_contact_custom_fields()] for raw field definitions.
#' @export
#' @examples
#' \dontrun{
#' cdf <- ac_deal_field_ids()
#'
#' # Simple: returns ID or errors if not found
#' ac_field_id(cdf, "source")                         # "42"
#'
#' # With type validation: checks value before API call
#' ac_field_id(cdf, "expected_close", "2026-06-01")   # validates date
#' ac_field_id(cdf, "deal_size", 50000)               # validates number
#' ac_field_id(cdf, "deal_size", "abc")               # errors: not numeric
#' }
ac_field_id <- function(registry, field_name, value = NULL) {
  entry <- .subset2(registry, field_name)
  if (is.null(entry)) {
    cli::cli_abort(c(
      "Field {.val {field_name}} not found in registry.",
      "i" = "Available fields: {.val {names(registry)}}",
      "i" = "Try refreshing with {.code force = TRUE}"
    ))
  }

  if (!is.null(value) && !is.na(entry$type)) {
    ac_validate_field_value(field_name, entry$type, value)
  }

  entry$id
}

#' Validate a Value Against a Field Type
#'
#' @param field_name Field name (for error messages)
#' @param field_type AC field type string (e.g., `"text"`, `"date"`,
#'   `"number"`, `"currency"`, `"dropdown"`, `"checkbox"`)
#' @param value The value to validate
#' @keywords internal
ac_validate_field_value <- function(field_name, field_type, value) {
  switch(field_type,
    number = , currency = {
      if (!is.numeric(value) && is.na(suppressWarnings(as.numeric(value)))) {
        cli::cli_abort(c(
          "Field {.field {field_name}} expects a {field_type} value.",
          "x" = "Got: {.val {value}}"
        ))
      }
    },
    date = , datetime = {
      parsed <- tryCatch(as.Date(value), error = function(e) NA)
      if (is.na(parsed)) {
        cli::cli_abort(c(
          "Field {.field {field_name}} expects a date value (YYYY-MM-DD).",
          "x" = "Got: {.val {value}}"
        ))
      }
    }
  )
  invisible(TRUE)
}
