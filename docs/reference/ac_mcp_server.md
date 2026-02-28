# ActiveCampaign MCP Server

Model Context Protocol server via mcptools for AI assistant integration.

Creates and starts an MCP (Model Context Protocol) server that exposes
ActiveCampaign API functions as tools for AI assistants like Claude.
Requires the `mcptools` package.

## Usage

``` r
ac_mcp_server()
```

## Value

An MCP server object (started)

## Details

The server exposes these tools:

- `ac_deals` — Search and list deals

- `ac_deal` — Get a single deal by ID

- `ac_create_deal` — Create a new deal

- `ac_update_deal` — Update a deal

- `ac_contacts` — Search and list contacts

- `ac_contact` — Get a single contact by ID

- `ac_create_contact` — Create a new contact

- `ac_tags` — List all tags

- `ac_deal_custom_fields_wide` — Get custom fields for deals

- `ac_deal_pipelines` — List pipelines

- `ac_deal_stages` — List stages

- `ac_users` — List users

- `ac_automations` — List automations

## Examples

``` r
if (FALSE) { # \dontrun{
# Start the MCP server (after authenticating)
ac_auth_from_env()
ac_mcp_server()
} # }
```
