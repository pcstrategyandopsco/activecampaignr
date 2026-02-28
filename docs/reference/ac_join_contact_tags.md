# Join Contacts with Tags

Fetches contacts and all tags, then looks up each contact's tags and
appends them as a comma-separated `tags` column.

## Usage

``` r
ac_join_contact_tags(...)
```

## Arguments

- ...:

  Arguments passed to
  [`ac_contacts()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_contacts.md)

## Value

A tibble of contacts with a `tags` column appended

## Examples

``` r
if (FALSE) { # \dontrun{
contacts <- ac_join_contact_tags()
} # }
```
