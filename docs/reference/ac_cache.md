# ActiveCampaign Cache Manager

RDS-based caching with TTL and incremental merge support.

Returns cached data if fresh (within TTL), otherwise calls `fn` and
caches the result.

## Usage

``` r
ac_cache(key, fn, ttl_minutes = 10, force = FALSE)
```

## Arguments

- key:

  Cache key (used as filename, e.g., `"deals"`)

- fn:

  A function that returns a tibble (called if cache is stale)

- ttl_minutes:

  Time-to-live in minutes (default: 10)

- force:

  If `TRUE`, bypasses the cache

## Value

The cached or freshly fetched tibble
