# Join Deals with Custom Fields

Fetches deals and their custom fields in wide format, then left-joins
them by deal ID. Prints a diagnostic summary showing match counts.

## Usage

``` r
ac_join_deal_fields(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ac_deals()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_deals.md)
  (e.g., `status`, `pipeline`, `owner`, `updated_after`)

## Value

A tibble of deals with custom field columns appended

## Examples

``` r
if (FALSE) { # \dontrun{
deals <- ac_join_deal_fields()
deals <- ac_join_deal_fields(status = 1)
} # }
```
