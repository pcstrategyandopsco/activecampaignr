# CLAUDE.md - activecampaignr Package

## Purpose

Tidy R client for the ActiveCampaign API v3. Built on httr2 with
automatic pagination, RDS caching, and MCP server support.

## Architecture

### Three-Layer Design

1.  **Request layer** (`R/request.R`) — httr2 request builder with auth
    headers, rate limiting (4 req/sec), retry with backoff, and response
    parsing
2.  **Cache layer** (`R/cache.R`) — RDS file cache with TTL, incremental
    merge (remove old IDs, append new, deduplicate)
3.  **Entity layer** (`R/deals.R`, `R/contacts.R`, etc.) — Thin wrappers
    using
    [`ac_paginate()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_paginate.md),
    [`ac_get_one()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_get_one.md),
    [`ac_post_one()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_post_one.md),
    [`ac_put_one()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_put_one.md),
    [`ac_delete_one()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_delete_one.md)

### Key Abstractions

| Function | Purpose |
|----|----|
| `ac_request(endpoint)` | Build httr2 request with auth + throttle + retry |
| `ac_paginate(endpoint, entity_key)` | Auto-paginate, return tibble |
| `ac_parse_records(records)` | List-of-lists → tibble, snake_case, type coercion |
| `ac_merge_records(stored, new)` | Incremental merge by ID |
| `ac_cache(key, fn, ttl)` | Cache-or-fetch wrapper |

### Auth State

Stored in internal environment `the` (not exported): - `the$base_url`,
`the$api_key`, `the$timezone`, `the$cache_dir` - Set via
[`ac_auth()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_auth.md)
or
[`ac_auth_from_env()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_auth_from_env.md)

## Running Tests

``` r

devtools::test()
```

Tests that don’t require API access: - `test-auth.R` — Auth state
management, error messages - `test-request.R` — Record parsing, type
coercion - `test-cache.R` — Merge logic, cache store/retrieve -
`test-utils.R` — Phone normalization (NZ/AU) - `test-deals.R` — Auth
requirement check

## Naming Convention

- `ac_<entity>s()` — List all (paginated)
- `ac_<entity>(id)` — Get one
- `ac_create_<entity>(...)` — POST
- `ac_update_<entity>(id, ...)` — PUT
- `ac_delete_<entity>(id)` — DELETE
- `ac_<entity>_<sub>()` — Sub-resources
- `ac_sync_<entity>()` — Cached incremental sync

## AC API v3 Endpoints Covered

| Endpoint | Functions |
|----|----|
| `deals` | `ac_deals`, `ac_deal`, `ac_create_deal`, `ac_update_deal`, `ac_delete_deal` |
| `dealCustomFieldMeta` | `ac_deal_custom_fields` |
| `dealCustomFieldData` | `ac_deal_custom_field_values`, `ac_deal_custom_fields_wide` |
| `deals/{id}/dealActivities` | `ac_deal_activities`, `ac_deal_won_date` |
| `dealGroups` | `ac_deal_pipelines` |
| `dealStages` | `ac_deal_stages` |
| `contacts` | `ac_contacts`, `ac_contact`, `ac_create_contact`, `ac_update_contact` |
| `fields` | `ac_contact_custom_fields` |
| `fieldValues` | `ac_contact_custom_fields_wide` |
| `contactTags` | `ac_contact_tags`, `ac_add_tag`, `ac_remove_tag` |
| `accounts` | `ac_accounts`, `ac_create_account` |
| `campaigns` | `ac_campaigns`, `ac_campaign_messages` |
| `dealTasks` | `ac_tasks`, `ac_create_task`, `ac_update_task` |
| `users` | `ac_users` |
| `automations` | `ac_automations`, `ac_trigger_automation` |
| `webhooks` | `ac_webhooks`, `ac_create_webhook`, `ac_delete_webhook` |
| `tags` | `ac_tags`, `ac_create_tag` |
| `lists` | `ac_lists`, `ac_list_contacts` |

## File Organization

    R/
      auth.R              — ac_auth(), credential management
      request.R           — httr2 request builder, pagination, parsing
      cache.R             — RDS cache with TTL, incremental merge
      deals.R             — Deal CRUD
      deal-custom-fields.R — Custom field pivot (long → wide)
      deal-activities.R   — Activity logs, won date extraction
      deal-pipelines.R    — Pipeline/stage metadata
      contacts.R          — Contact CRUD
      contact-custom-fields.R — Contact custom field pivot
      contact-tags.R      — Tag management
      accounts.R          — Account CRUD
      campaigns.R         — Campaign data
      tasks.R             — Task CRUD
      users.R             — User listing
      automations.R       — Automation listing/triggering
      webhooks.R          — Webhook management
      tags.R              — Tag management
      lists.R             — List management
      sync.R              — Incremental sync with cache
      mcp.R               — MCP server via mcptools
      utils.R             — Phone normalization, URL builders

## Dependencies

- **Imports:** httr2, tibble, dplyr, tidyr, rlang, cli, janitor, glue,
  purrr
- **Suggests:** mcptools, officer, shiny, future, progressr, testthat,
  httptest2, withr, config

## When Making Changes

1.  Run
    [`devtools::test()`](https://devtools.r-lib.org/reference/test.html)
    after any logic changes
2.  Keep IDs as character (not numeric) to avoid integer overflow
3.  All datetime columns use the configured timezone
    ([`ac_get_tz()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_get_tz.md))
4.  Response parsing goes through
    [`ac_parse_records()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_parse_records.md)
    for consistency
5.  New entity functions should use
    `ac_paginate/ac_get_one/ac_post_one/ac_put_one/ac_delete_one`
6.  Update NAMESPACE if adding exports
