# Authenticate from Environment Variables

Reads `ACTIVECAMPAIGN_URL` and `ACTIVECAMPAIGN_API_KEY` from the
environment. Optionally reads from a `config.yml` file.

## Usage

``` r
ac_auth_from_env(
  config_file = NULL,
  timezone = "UTC",
  cache_dir = "~/.activecampaignr/cache"
)
```

## Arguments

- config_file:

  Path to a `config.yml` file (optional). If provided and the `config`
  package is installed, reads credentials from it.

- timezone:

  Timezone for datetime conversion (default: `"UTC"`)

- cache_dir:

  Directory for RDS cache files

## Value

Invisibly returns `TRUE` on success
