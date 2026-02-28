# Extract the Actual Won Date for a Deal

Parses the deal activity log to find the first time the deal was moved
to "Won" status. This is more reliable than `mdate` which reflects the
last modification time.

## Usage

``` r
ac_deal_won_date(deal_id)
```

## Arguments

- deal_id:

  Deal ID

## Value

A POSIXct datetime, or `NA` if no won event found

## Examples

``` r
if (FALSE) { # \dontrun{
won_date <- ac_deal_won_date("12345")
} # }
```
