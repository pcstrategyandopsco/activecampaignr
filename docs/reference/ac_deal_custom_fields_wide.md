# Get Deal Custom Fields in Wide Format

Fetches custom field values and pivots them so each deal is one row and
each custom field is a column. Column names are the field labels.

## Usage

``` r
ac_deal_custom_fields_wide(deal_id = NULL)
```

## Arguments

- deal_id:

  Optional deal ID(s) to filter by

## Value

A tibble with `deal_id` + one column per custom field

## Examples

``` r
if (FALSE) { # \dontrun{
# Wide format custom fields for all deals
cf <- ac_deal_custom_fields_wide()

# For specific deals
cf <- ac_deal_custom_fields_wide(deal_id = c("123", "456"))
} # }
```
