# Parse a List of API Records into a Tibble

Converts a list of records (each a named list) into a flat tibble with
snake_case column names and proper types.

## Usage

``` r
ac_parse_records(records)
```

## Arguments

- records:

  A list of named lists from the API response

## Value

A tibble
