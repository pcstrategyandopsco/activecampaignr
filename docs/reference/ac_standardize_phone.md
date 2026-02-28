# Standardize Phone Number

Normalizes a phone number to E.164 international format. If the `dialr`
package is installed, supports all countries via Google's
libphonenumber. Otherwise, falls back to built-in NZ/AU rules.

## Usage

``` r
ac_standardize_phone(phone, default_region = "NZ")
```

## Arguments

- phone:

  A character vector of phone numbers

- default_region:

  ISO 3166-1 alpha-2 country code assumed for numbers without a country
  prefix (default: `"NZ"`)

## Value

A character vector of E.164 formatted phone strings (e.g.,
`"+6421234567"`), or `NA_character_` for unparseable numbers

## Examples

``` r
ac_standardize_phone("021 123 4567")          # "+6421234567"
#> [1] "+64211234567"
ac_standardize_phone("+64211234567")           # "+64211234567"
#> [1] "+64211234567"
ac_standardize_phone("+61412345678")           # "+61412345678"
#> [1] "+61412345678"
ac_standardize_phone("(555) 867-5309", "US")   # "+15558675309" (with dialr)
#> [1] NA
ac_standardize_phone(NA)                        # NA
#> [1] NA
```
