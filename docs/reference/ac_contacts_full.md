# Get Contacts with All Related Data

Fetches contacts and joins custom fields and tags into a single
analysis-ready tibble.

## Usage

``` r
ac_contacts_full(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ac_contacts()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_contacts.md)
  (e.g., `email`, `search`, `updated_after`)

## Value

A tibble of contacts with custom field columns and a `tags` column

## Examples

``` r
if (FALSE) { # \dontrun{
contacts <- ac_contacts_full()
} # }
```
