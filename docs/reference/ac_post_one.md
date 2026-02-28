# Perform a Create (POST) Request

Perform a Create (POST) Request

## Usage

``` r
ac_post_one(endpoint, entity_key, body)
```

## Arguments

- endpoint:

  API endpoint

- entity_key:

  Wrapper key for the body (e.g., `"deal"`)

- body:

  Named list of fields

## Value

A single-row tibble of the created entity
