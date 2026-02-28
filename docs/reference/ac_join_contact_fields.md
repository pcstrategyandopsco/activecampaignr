# Join Contacts with Custom Fields

Fetches contacts and their custom fields in wide format, then left-joins
them by contact ID. Prints a diagnostic summary showing match counts.

## Usage

``` r
ac_join_contact_fields(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ac_contacts()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_contacts.md)
  (e.g., `email`, `search`, `updated_after`)

## Value

A tibble of contacts with custom field columns appended

## Examples

``` r
if (FALSE) { # \dontrun{
contacts <- ac_join_contact_fields()
contacts <- ac_join_contact_fields(email = "user@example.com")
} # }
```
