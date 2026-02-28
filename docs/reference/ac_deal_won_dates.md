# Batch Extract Won Dates for Multiple Deals

Iterates over deal IDs, fetching activity logs and extracting the actual
won date for each. Includes rate limiting.

## Usage

``` r
ac_deal_won_dates(deal_ids, .progress = NULL)
```

## Arguments

- deal_ids:

  Character vector of deal IDs

- .progress:

  Optional progressr callback

## Value

A tibble with columns: deal_id, won_date
