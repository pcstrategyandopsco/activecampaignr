.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "activecampaignr ", utils::packageVersion("activecampaignr"),
    " - Tidy interface to ActiveCampaign API v3",
    "\nRun ac_auth() or ac_auth_from_env() to get started."
  )
}

.onLoad <- function(libname, pkgname) {
  the$cache_dir <- path.expand("~/.activecampaignr/cache")
  the$deal_field_registry <- NULL
  the$deal_field_registry_time <- NULL
  the$contact_field_registry <- NULL
  the$contact_field_registry_time <- NULL
}
