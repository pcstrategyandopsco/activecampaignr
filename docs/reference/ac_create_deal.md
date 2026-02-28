# Create a Deal

Create a Deal

## Usage

``` r
ac_create_deal(
  title,
  value = 0,
  currency = "usd",
  pipeline = NULL,
  stage = NULL,
  owner = NULL,
  contact = NULL,
  ...
)
```

## Arguments

- title:

  Deal title

- value:

  Deal value in cents (integer)

- currency:

  Currency code (e.g., `"nzd"`, `"usd"`)

- pipeline:

  Pipeline (group) ID

- stage:

  Stage ID

- owner:

  Owner (user) ID

- contact:

  Contact ID

- ...:

  Additional fields as named arguments

## Value

A single-row tibble of the created deal
