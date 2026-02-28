# Get Deals with All Related Data

Fetches deals and joins custom fields, stage names, pipeline names, and
owner names into a single analysis-ready tibble.

## Usage

``` r
ac_deals_full(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ac_deals()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_deals.md)
  (e.g., `status`, `pipeline`, `owner`, `updated_after`)

## Value

A tibble of deals with columns from custom fields, stage name, pipeline
name, owner name, and owner email

## Examples

``` r
if (FALSE) { # \dontrun{
# Everything in one call
deals <- ac_deals_full()

# Won deals, fully joined
won <- ac_deals_full(status = 1)
} # }
```
