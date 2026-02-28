# Caching and Incremental Sync

## Overview

activecampaignr uses an RDS-based cache to avoid redundant API calls.
The sync functions implement a three-tier strategy:

1.  **Cache hit** — If data was fetched within the TTL, return it
    instantly
2.  **Incremental sync** — If stored data exists, only fetch recent
    changes and merge them
3.  **Full sync** — Fetch everything from scratch

## How It Works

``` r

library(activecampaignr)
ac_auth_from_env()

# The sync function handles everything:
result <- ac_sync_deals(
  lookback_days = 5,     # How far back to check for changes

  ttl_minutes = 10,      # Cache freshness threshold
  force = FALSE,         # Set TRUE to bypass cache
  include_custom_fields = TRUE
)
```

### Cache Storage

By default, cache files are stored in `~/.activecampaignr/cache/`:

``` r

# Check current cache directory
ac_cache_path()

# Change cache directory
ac_cache_path("~/my-project/cache")

# See what's cached
ac_cache_status()
# # A tibble: 3 x 5
#   key                  rows age_minutes size_kb path
#   <chr>               <int>       <dbl>   <dbl> <chr>
# 1 contacts             2340       15.2    450.1 ~/.activecampaignr/cache/contacts.rds
# 2 deal_custom_fields    890        5.3    120.5 ~/.activecampaignr/cache/deal_custom_fields.rds
# 3 deals                 890        5.3    280.8 ~/.activecampaignr/cache/deals.rds
```

### Merge Strategy

When doing incremental sync, new/updated records replace old ones:

    Stored: [A1, B1, C1]  (1000 records)
    Fetched: [B2, D1]     (2 records modified in last 5 days)
    Merged:  [A1, B2, C1, D1]  (1001 records — B updated, D added)

The merge uses the record ID as the key: old versions are removed, new
versions are appended, then deduplicated.

## Parallel Sync with future

For production pipelines, sync deals and contacts in parallel:

``` r

library(future)
plan(multisession, workers = 2)

library(progressr)
handlers(global = TRUE)

with_progress({
  p <- progressor(steps = 10)

  f_deals <- future({
    ac_sync_deals(.progress = p)
  }, seed = TRUE)

  f_contacts <- future({
    ac_sync_contacts(.progress = p)
  }, seed = TRUE)

  deals_result <- value(f_deals)
  contacts <- value(f_contacts)
})

plan(sequential)
```

## The `ac_cache()` Helper

For custom caching scenarios, use the low-level
[`ac_cache()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_cache.md)
function:

``` r

# Cache any expensive computation
pipelines <- ac_cache("pipelines", function() {
  ac_deal_pipelines()
}, ttl_minutes = 60)  # Pipelines rarely change

# Force refresh
pipelines <- ac_cache("pipelines", function() {
  ac_deal_pipelines()
}, force = TRUE)
```

## Clearing Cache

``` r

# Clear everything
ac_cache_clear()

# Clear a specific entity
ac_cache_clear("deals")
ac_cache_clear("contacts")
```
