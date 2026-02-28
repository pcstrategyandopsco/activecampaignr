# ActiveCampaign Deals

CRUD operations for ActiveCampaign deals.

Retrieves all deals with automatic pagination. Supports filtering by
status, owner, pipeline, stage, and modification date.

## Usage

``` r
ac_deals(
  status = NULL,
  owner = NULL,
  pipeline = NULL,
  stage = NULL,
  updated_after = NULL,
  search = NULL,
  .progress = NULL
)
```

## Arguments

- status:

  Filter by status: `0` = open, `1` = won, `2` = lost

- owner:

  Filter by deal owner ID

- pipeline:

  Filter by pipeline (group) ID

- stage:

  Filter by stage ID

- updated_after:

  Only return deals modified after this date (format: `"YYYY-MM-DD"`)

- search:

  Search string to match against deal titles

- .progress:

  Optional progressr callback

## Value

A tibble of deals

## Examples

``` r
if (FALSE) { # \dontrun{
# All deals
deals <- ac_deals()

# Won deals only
won <- ac_deals(status = 1)

# Deals modified in the last week
recent <- ac_deals(updated_after = Sys.Date() - 7)
} # }
```
