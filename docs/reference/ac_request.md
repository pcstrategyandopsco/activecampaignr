# ActiveCampaign Request Builder

Low-level request construction, pagination, and rate limiting.

Constructs an httr2 request object with authentication headers, rate
limiting, and retry logic pre-configured.

## Usage

``` r
ac_request(endpoint, method = "GET", body = NULL, query = NULL)
```

## Arguments

- endpoint:

  API endpoint path (e.g., `"deals"`, `"contacts/123"`)

- method:

  HTTP method: `"GET"`, `"POST"`, `"PUT"`, `"DELETE"`

- body:

  Request body (list), auto-serialized to JSON for POST/PUT

- query:

  Named list of query parameters

## Value

An httr2 request object
