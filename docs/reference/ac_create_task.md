# Create a Task

Create a Task

## Usage

``` r
ac_create_task(
  title,
  deal_id = NULL,
  due_date = NULL,
  type = NULL,
  assignee = NULL,
  note = NULL,
  ...
)
```

## Arguments

- title:

  Task title

- deal_id:

  Deal ID to associate with

- due_date:

  Due date (character `"YYYY-MM-DD"` or Date)

- type:

  Task type ID

- assignee:

  User ID to assign to

- note:

  Task note/body

- ...:

  Additional fields

## Value

A single-row tibble
