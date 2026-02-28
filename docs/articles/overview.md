# Vignette Overview

This page provides a guided tour of the activecampaignr vignettes. Each
one is self-contained, but they build on each other in a logical order.

## 1. Getting Started

**[Getting Started with
activecampaignr](https://pcstrategyandopsco.github.io/activecampaignr/articles/getting-started.md)**
covers authentication, your first API call, and basic data retrieval.
Start here if you are new to the package.

| Topic | What you will learn |
|----|----|
| Authentication | [`ac_auth()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_auth.md) and [`ac_auth_from_env()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_auth_from_env.md) setup |
| Fetching data | [`ac_deals()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_deals.md), [`ac_contacts()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_contacts.md), filtering and search |
| Custom fields | Wide-format pivot with [`ac_deal_custom_fields_wide()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_deal_custom_fields_wide.md) |
| Convenience joins | [`ac_deals_full()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_deals_full.md) for a single ready-to-analyse tibble |

## 2. Caching and Incremental Sync

**[Caching and Incremental
Sync](https://pcstrategyandopsco.github.io/activecampaignr/articles/caching-and-sync.md)**
explains how to avoid redundant API calls in production workflows.

| Topic | What you will learn |
|----|----|
| Three-tier strategy | When to use [`ac_sync_deals()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_sync_deals.md) vs [`ac_deals()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_deals.md) vs [`ac_cache_path()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_cache_path.md) |
| Incremental sync | Fetch only records modified since your last sync |
| Parallel sync | Run [`ac_sync_deals()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_sync_deals.md) and [`ac_sync_contacts()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_sync_contacts.md) with future |
| Gotchas | Deleted records, TTL behaviour, multi-account setups |
| Cache management | When and how to flush with [`ac_cache_clear()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_cache_clear.md) |

## 3. MCP Integration for AI Assistants

**[MCP
Integration](https://pcstrategyandopsco.github.io/activecampaignr/articles/mcp-integration.md)**
shows how to expose your CRM as tools for AI assistants like Claude.

| Topic | What you will learn |
|----|----|
| MCP server setup | [`ac_mcp_server()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_mcp_server.md) configuration |
| Available tools | Which functions are exposed and how AI assistants call them |
| Security | Scoping access for read-only or read-write use |

## 4. Pipeline Analysis with officer

**[Pipeline
Analysis](https://pcstrategyandopsco.github.io/activecampaignr/articles/pipeline-analysis.md)**
walks through building a PowerPoint pipeline report with native editable
charts.

| Topic | What you will learn |
|----|----|
| mschart | Bar charts, line charts that recipients can edit in PowerPoint |
| ggplot fallback | When to use `dml(ggobj = ...)` for complex visualisations |
| officer assembly | Title slides, chart slides, summary tables |
| Output | A `.pptx` file ready for stakeholders |

## 5. Advertising Effectiveness Analysis

**[Ad
Effectiveness](https://pcstrategyandopsco.github.io/activecampaignr/articles/ad-effectiveness.md)**
is the most detailed analysis vignette. It correlates advertising spend
with sales outcomes.

| Topic | What you will learn |
|----|----|
| Cost per lead / cost per sale | Daily and weekly CPL and CPS |
| Pipeline velocity | How long leads take to convert |
| Windowed attribution | Lagging spend by median velocity for fairer comparison |
| Per-deal attribution | Attributing each sale to the spend on the day its lead was created |
| Lag correlation | Optimal spend-to-sales lag across 0-12 weeks |

## 6. Interactive Deal Dashboard with Shiny

**[Shiny Deal
Dashboard](https://pcstrategyandopsco.github.io/activecampaignr/articles/shiny-deal-dashboard.md)**
provides a template for an interactive deal explorer.

| Topic      | What you will learn                                 |
|------------|-----------------------------------------------------|
| Filters    | Pipeline, owner, date range, status                 |
| Live sync  | Refresh data from the API within the app            |
| Deployment | Running the bundled app from `inst/shiny-examples/` |

## 7. Campaign ROI Report with officer

**[Campaign
ROI](https://pcstrategyandopsco.github.io/activecampaignr/articles/campaign-roi.md)**
builds a branded Word document summarising campaign performance.

| Topic            | What you will learn                            |
|------------------|------------------------------------------------|
| Campaign metrics | Open rates, click rates, revenue attribution   |
| officer for Word | Styled tables and paragraphs in `.docx` output |
| Automation       | Generating reports on a schedule               |

## Suggested reading order

If you are new to activecampaignr, work through them in this order:

1.  Getting Started (required)
2.  Caching and Incremental Sync (recommended for production use)
3.  One analysis vignette that matches your use case (4, 5, 6, or 7)
4.  MCP Integration (if using AI assistants)
