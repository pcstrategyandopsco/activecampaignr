# Auto-Paginate an ActiveCampaign API Endpoint

Fetches all pages from a paginated endpoint. ActiveCampaign uses
offset-based pagination with a `meta.total` field.

## Usage

``` r
ac_paginate(
  endpoint,
  entity_key,
  query = list(),
  limit = 100L,
  .progress = NULL
)
```

## Arguments

- endpoint:

  API endpoint path (e.g., `"deals"`)

- entity_key:

  The key in the response containing the entity list (e.g., `"deals"`,
  `"contacts"`)

- query:

  Additional query parameters (filters, sorting, etc.)

- limit:

  Number of records per page (default: 100, AC max)

- .progress:

  Optional progressr callback (`p = NULL` for none)

## Value

A tibble of all records
