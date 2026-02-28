# activecampaignr

A **tidy**, **cached**, and **MCP-ready** R client for the
[ActiveCampaign API
v3](https://developers.activecampaign.com/reference/overview).

**Documentation:**
[pcstrategyandopsco.github.io/activecampaignr](https://pcstrategyandopsco.github.io/activecampaignr/)

## Overview

`activecampaignr` gives R users direct analytic access to their
ActiveCampaign CRM. Pull your full deal pipeline into a tibble, join
custom fields in wide format, and feed the result straight into dplyr,
ggplot2, or Shiny without writing a single API call by hand. Built-in
caching means repeated analysis runs hit disk instead of the API, and
incremental sync keeps your local data current without re-fetching
everything.

The dataframes are correctly typed, and a number of convenience
functions are included to make it easier to join data and perform
analysis.

Typical use cases:

- **Pipeline analytics** — win rates by owner, stage, pathway, or time
  period; funnel conversion rates; deal velocity (days per stage)
- **Contact enrichment** — merge CRM contacts with external data via
  email or phone, with NZ/AU phone normalization built in
- **Campaign performance** — open rates, click rates, and revenue
  attribution across campaigns
- **Custom field analysis** — pivot ActiveCampaign’s long-format custom
  fields into one-row-per-deal wide format ready for modelling or
  reporting
- **Automated reporting** — combine with officer for PowerPoint/Word
  reports or Shiny for interactive dashboards
- **AI-assisted CRM queries** — expose your pipeline as MCP tools so AI
  assistants can answer natural language questions about your deals and
  contacts

## Features

| Feature | Detail |
|----|----|
| Tidy outputs | All functions return tibbles with snake_case columns |
| Automatic pagination | Fetch thousands of records without manual page handling |
| Rate limiting & retry | Built-in throttling (4 req/sec) and exponential backoff |
| RDS caching | Incremental sync fetches only recent changes |
| Full CRUD | Read, create, update, delete for deals, contacts, tags, and more |
| Custom fields | Wide-format pivot, one row per entity, one column per field |
| MCP server | Expose your CRM as tools for AI assistants via mcptools |
| NZ/AU phone normalization | Standardize phone numbers for matching |

## Installation

``` r

# Install from GitHub
# install.packages("pak")
pak::pak("pcstrategyandopsco/activecampaignr")
```

## Quick Start

``` r

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

| Vignette | Description |
|----|----|
| [Getting Started](https://pcstrategyandopsco.github.io/activecampaignr/articles/getting-started.html) | Auth, first API call, caching |
| [Caching and Sync](https://pcstrategyandopsco.github.io/activecampaignr/articles/caching-and-sync.html) | Incremental sync, parallel with future |
| [MCP Integration](https://pcstrategyandopsco.github.io/activecampaignr/articles/mcp-integration.html) | AI assistant tool setup |
| [Pipeline Analysis](https://pcstrategyandopsco.github.io/activecampaignr/articles/pipeline-analysis.html) | Win rates, velocity, PowerPoint reports |
| [Ad Effectiveness](https://pcstrategyandopsco.github.io/activecampaignr/articles/ad-effectiveness.html) | CPL, CPS, velocity, windowed attribution |
| [Shiny Deal Dashboard](https://pcstrategyandopsco.github.io/activecampaignr/articles/shiny-deal-dashboard.html) | Interactive deal explorer |
| [Campaign ROI](https://pcstrategyandopsco.github.io/activecampaignr/articles/campaign-roi.html) | Campaign performance Word report |

## Why This Package?

This package builds on the foundation laid by
[`ractivecampaign`](https://github.com/rwColumn/ractivecampaign), which
pioneered R access to the ActiveCampaign API. I’m grateful for that
work. It proved the value of an R-native AC client and informed many of
the patterns used here.

However, production use at scale revealed gaps that warranted a
ground-up rebuild:

| Capability | Detail |
|----|----|
| Broader API coverage | `ractivecampaign` covers deals and contacts; production CRM pipelines need accounts, campaigns, tasks, tags, lists, automations, and webhooks |
| Automatic pagination | Fetching thousands of records shouldn’t require manual offset loops |
| Caching and incremental sync | Repeated API calls for unchanged data waste time and hit rate limits; this package caches to RDS and only fetches recent changes |
| Modern HTTP backend | Built on httr2 with native rate limiting (`req_throttle`) and retry with exponential backoff (`req_retry`), replacing manual [`Sys.sleep()`](https://rdrr.io/r/base/Sys.sleep.html) and `retry()` calls |
| Custom field pivot | ActiveCampaign stores custom fields in long format (one row per field); this package provides wide format out of the box (one row per entity, one column per field) |
| MCP integration | Expose your CRM as tools for AI assistants via mcptools, enabling natural language queries against your deal and contact data |
| Write operations | Full CRUD (create, read, update, delete) for all entities, not just read |

## Acknowledgements

This package was inspired by and builds on the work of
[`ractivecampaign`](https://github.com/rwColumn/ractivecampaign). Thank
you for making ActiveCampaign accessible to the R community.

## License

MIT
