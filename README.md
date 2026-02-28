# activecampaignr

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

A **tidy**, **cached**, and **MCP-ready** R client for the [ActiveCampaign API v3](https://developers.activecampaign.com/reference/overview).

## Why This Package?

This package builds on the foundation laid by [`ractivecampaign`](https://github.com/rwColumn/ractivecampaign), which pioneered R access to the ActiveCampaign API. We're grateful for that work — it proved the value of an R-native AC client and informed many of the patterns used here.

However, production use at scale revealed gaps that warranted a ground-up rebuild:

- **Broader API coverage** — `ractivecampaign` covers deals and contacts; production CRM pipelines need accounts, campaigns, tasks, tags, lists, automations, and webhooks
- **Automatic pagination** — Fetching thousands of records shouldn't require manual offset loops
- **Caching and incremental sync** — Repeated API calls for unchanged data waste time and hit rate limits; this package caches to RDS and only fetches recent changes
- **Modern HTTP backend** — Built on httr2 with native rate limiting (`req_throttle`) and retry with exponential backoff (`req_retry`), replacing manual `Sys.sleep()` and `retry()` calls
- **Custom field pivot** — ActiveCampaign stores custom fields in long format (one row per field); this package provides wide format out of the box (one row per entity, one column per field)
- **MCP integration** — Expose your CRM as tools for AI assistants via mcptools, enabling natural language queries against your deal and contact data
- **Write operations** — Full CRUD (create, read, update, delete) for all entities, not just read

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
pak::pak("pcstrategyandopsco/activecampaignr")
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

## Vignettes

- [Getting Started](vignettes/getting-started.Rmd) — Auth, first API call, caching
- [Caching and Sync](vignettes/caching-and-sync.Rmd) — Incremental sync, parallel with future
- [MCP Integration](vignettes/mcp-integration.Rmd) — AI assistant tool setup
- [Pipeline Analysis](vignettes/pipeline-analysis.Rmd) — Win rates, velocity, PowerPoint reports
- [Shiny Deal Dashboard](vignettes/shiny-deal-dashboard.Rmd) — Interactive deal explorer
- [Campaign ROI](vignettes/campaign-roi.Rmd) — Campaign performance Word report

## Acknowledgements

This package was inspired by and builds on the work of [`ractivecampaign`](https://github.com/rwColumn/ractivecampaign). Thank you for making ActiveCampaign accessible to the R community.

## License

MIT
