# activecampaignr

<!-- badges: start -->
[![R-CMD-check](https://github.com/peeyooshchandra/activecampaignr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/peeyooshchandra/activecampaignr/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

A **tidy**, **cached**, and **MCP-ready** R client for the [ActiveCampaign API v3](https://developers.activecampaign.com/reference/overview).

## Features

- **Tidy outputs** — All functions return tibbles with snake_case columns
- **Automatic pagination** — Fetch thousands of records without manual page handling
- **Rate limiting & retry** — Built-in throttling (4 req/sec) and exponential backoff
- **RDS caching** — Incremental sync fetches only recent changes
- **Full CRUD** — Read, create, update, delete for deals, contacts, tags, and more
- **Custom fields** — Wide-format pivot (one row per entity, one column per field)
- **MCP server** — Expose your CRM as tools for AI assistants via mcptools
- **NZ/AU phone normalization** — Standardize phone numbers for matching

## Installation

```r
# Install from GitHub
# install.packages("pak")
pak::pak("peeyooshchandra/activecampaignr")
```

## Quick Start

```r
library(activecampaignr)

# Authenticate
ac_auth(
  url = "https://yourname.api-us1.com",
  api_key = "your-api-key"
)
# Or: ac_auth_from_env()  # reads ACTIVECAMPAIGN_URL + ACTIVECAMPAIGN_API_KEY

# Fetch deals
deals <- ac_deals()
won_deals <- ac_deals(status = 1)

# Custom fields in wide format
cf <- ac_deal_custom_fields_wide()

# Incremental sync with caching
result <- ac_sync_deals()
deals <- result$deals
```

## vs ractivecampaign

| Feature | ractivecampaign | activecampaignr |
|---------|----------------|-----------------|
| API coverage | Deals, contacts | Deals, contacts, accounts, campaigns, tasks, tags, lists, automations, webhooks |
| Output format | Data frames | Tidy tibbles (snake_case, proper types) |
| Pagination | Manual | Automatic |
| Rate limiting | Manual `Sys.sleep()` | Built-in `req_throttle()` |
| Retry logic | Manual `retry()` | Built-in `req_retry()` with backoff |
| Caching | None | RDS with TTL + incremental merge |
| Custom fields | Long format only | Long + wide format pivot |
| HTTP backend | httr | httr2 |
| MCP support | No | Yes (via mcptools) |
| Write operations | Limited | Full CRUD for all entities |

## Vignettes

- [Getting Started](vignettes/getting-started.Rmd) — Auth, first API call, caching
- [Caching and Sync](vignettes/caching-and-sync.Rmd) — Incremental sync, parallel with future
- [MCP Integration](vignettes/mcp-integration.Rmd) — AI assistant tool setup
- [Pipeline Analysis](vignettes/pipeline-analysis.Rmd) — Win rates, velocity, PowerPoint reports
- [Shiny Deal Dashboard](vignettes/shiny-deal-dashboard.Rmd) — Interactive deal explorer
- [Campaign ROI](vignettes/campaign-roi.Rmd) — Campaign performance Word report

## License

MIT
