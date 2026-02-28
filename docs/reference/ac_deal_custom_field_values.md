# Get All Deal Custom Field Values

Fetches the raw custom field values for all deals (long format: one row
per deal-field combination).

## Usage

``` r
ac_deal_custom_field_values(deal_id = NULL)
```

## Arguments

- deal_id:

  Optional deal ID(s) to filter by

## Value

A tibble with columns: id, deal_id, custom_field_meta_id,
custom_field_datum_value
