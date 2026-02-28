# Create a Webhook

Create a Webhook

## Usage

``` r
ac_create_webhook(name, url, events, sources = "0")
```

## Arguments

- name:

  Webhook name

- url:

  URL to receive webhook POSTs

- events:

  Character vector of event names (e.g., `"deal_add"`, `"contact_add"`,
  `"deal_update"`)

- sources:

  Character vector of source IDs (e.g., `"0"` for all)

## Value

A single-row tibble
