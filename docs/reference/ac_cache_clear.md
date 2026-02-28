# Clear the Cache

Removes all cached RDS files, or a specific key.

## Usage

``` r
ac_cache_clear(key = NULL)
```

## Arguments

- key:

  Optional specific cache key to clear. If `NULL`, clears all.

## Value

Invisibly returns the number of files removed
