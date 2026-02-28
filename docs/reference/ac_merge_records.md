# Merge Cached and New Records

Replaces old versions of updated records (by ID) and appends new ones.
Used by incremental sync functions.

## Usage

``` r
ac_merge_records(stored, new_data, id_col = "id")
```

## Arguments

- stored:

  Existing cached tibble

- new_data:

  Freshly fetched tibble

- id_col:

  Column name used as the unique identifier (default: `"id"`)

## Value

Merged tibble
