# Perform an Update (PUT) Request

Perform an Update (PUT) Request

## Usage

``` r
ac_put_one(endpoint, entity_key, body)
```

## Arguments

- endpoint:

  API endpoint (e.g., `"deals/123"`)

- entity_key:

  Wrapper key for the body

- body:

  Named list of fields to update

## Value

A single-row tibble of the updated entity
