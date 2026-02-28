# Join Deals with Pipeline Names

Fetches deals and pipeline definitions, then left-joins to resolve
pipeline (group) IDs to human-readable pipeline names.

## Usage

``` r
ac_join_deal_pipelines(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ac_deals()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_deals.md)

## Value

A tibble of deals with `pipeline_title` column appended

## Examples

``` r
if (FALSE) { # \dontrun{
deals <- ac_join_deal_pipelines()
} # }
```
