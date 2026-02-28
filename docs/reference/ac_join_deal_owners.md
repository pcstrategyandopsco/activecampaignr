# Join Deals with Owner Names

Fetches deals and users, then left-joins to resolve owner IDs to user
names and emails.

## Usage

``` r
ac_join_deal_owners(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ac_deals()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_deals.md)

## Value

A tibble of deals with `owner_name` and `owner_email` columns appended

## Examples

``` r
if (FALSE) { # \dontrun{
deals <- ac_join_deal_owners()
} # }
```
