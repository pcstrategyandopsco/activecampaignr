# Incremental Contact Sync

Fetches contacts with caching, similar to
[`ac_sync_deals()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_sync_deals.md).

## Usage

``` r
ac_sync_contacts(
  lookback_days = 5,
  ttl_minutes = 10,
  force = FALSE,
  .progress = NULL
)
```

## Arguments

- lookback_days:

  Days to look back for incremental sync

- ttl_minutes:

  Cache TTL in minutes

- force:

  Bypass cache

- .progress:

  Optional progressr callback

## Value

A tibble of contacts
