# Join Deals with Stage Names

Fetches deals and stage definitions, then left-joins to resolve stage
IDs to human-readable stage names.

## Usage

``` r
ac_join_deal_stages(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ac_deals()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_deals.md)

## Value

A tibble of deals with `stage_title` column appended

## Examples

``` r
if (FALSE) { # \dontrun{
deals <- ac_join_deal_stages()
} # }
```
