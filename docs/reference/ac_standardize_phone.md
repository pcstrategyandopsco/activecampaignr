# Standardize Phone Number (NZ/AU)

Normalizes a phone number to international format (`+64` for NZ, `+61`
for AU). Handles local formats with and without leading zero, and
various country code prefixes.

## Usage

``` r
ac_standardize_phone(phone)
```

## Arguments

- phone:

  A character string containing a phone number

## Value

A standardized phone string (e.g., `"+6421234567"`), or `NA_character_`
if the number cannot be parsed

## Examples

``` r
ac_standardize_phone("021 123 4567")   # "+6421234567"
#> [1] "+64211234567"
ac_standardize_phone("+64211234567")    # "+64211234567"
#> [1] "+64211234567"
ac_standardize_phone("0412345678")      # "+64412345678"
#> [1] "+64412345678"
ac_standardize_phone("+61412345678")    # "+61412345678"
#> [1] "+61412345678"
ac_standardize_phone(NA)                # NA
#> [1] NA
```
