# Incremental Deal Sync

Fetches deals from ActiveCampaign with intelligent caching:

1.  If the cache is fresh (within TTL), returns cached data

2.  If stored data exists, performs incremental sync (recent changes
    only)

3.  Otherwise, performs a full sync

## Usage

``` r
ac_sync_deals(
  lookback_days = 5,
  ttl_minutes = 10,
  force = FALSE,
  include_custom_fields = TRUE,
  .progress = NULL
)
```

## Arguments

- lookback_days:

  Number of days to look back for incremental sync (default: 5)

- ttl_minutes:

  Cache time-to-live in minutes (default: 10)

- force:

  If `TRUE`, bypasses cache and fetches everything

- include_custom_fields:

  If `TRUE`, also fetches custom fields in wide format (default: `TRUE`)

- .progress:

  Optional progressr callback

## Value

A list with `$deals` (tibble) and optionally `$custom_fields` (tibble)

## Examples

``` r
if (FALSE) { # \dontrun{
result <- ac_sync_deals()
deals <- result$deals

# Force full refresh
result <- ac_sync_deals(force = TRUE)
} # }
```
