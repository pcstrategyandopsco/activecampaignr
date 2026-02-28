# ActiveCampaign Contacts

CRUD operations for ActiveCampaign contacts.

Retrieves all contacts with automatic pagination.

## Usage

``` r
ac_contacts(
  email = NULL,
  search = NULL,
  list_id = NULL,
  tag_id = NULL,
  updated_after = NULL,
  .progress = NULL
)
```

## Arguments

- email:

  Filter by exact email

- search:

  Search string (matches name, email, phone)

- list_id:

  Filter by list membership

- tag_id:

  Filter by tag

- updated_after:

  Only return contacts modified after this datetime

- .progress:

  Optional progressr callback

## Value

A tibble of contacts

## Examples

``` r
if (FALSE) { # \dontrun{
contacts <- ac_contacts()
contacts <- ac_contacts(email = "user@example.com")
} # }
```
