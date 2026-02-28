# ActiveCampaign Authentication

Set up authentication for the ActiveCampaign API.

Stores credentials for subsequent API calls. Validates the connection
with a test request to the API.

## Usage

``` r
ac_auth(url, api_key, timezone = "UTC", cache_dir = "~/.activecampaignr/cache")
```

## Arguments

- url:

  Your ActiveCampaign API URL (e.g., `"https://yourname.api-us1.com"`)

- api_key:

  Your ActiveCampaign API key

- timezone:

  Timezone for datetime conversion (default: `"UTC"`)

- cache_dir:

  Directory for RDS cache files (default: `"~/.activecampaignr/cache"`)

## Value

Invisibly returns `TRUE` on success

## Examples

``` r
if (FALSE) { # \dontrun{
ac_auth(
  url = "https://yourname.api-us1.com",
  api_key = "your-api-key-here"
)
} # }
```
