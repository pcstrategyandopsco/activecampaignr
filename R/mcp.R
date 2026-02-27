#' @title ActiveCampaign MCP Server
#' @name ac_mcp_server
#' @description Model Context Protocol server via mcptools for AI assistant integration.
NULL

#' Start an MCP Server for ActiveCampaign
#'
#' Creates and starts an MCP (Model Context Protocol) server that exposes
#' ActiveCampaign API functions as tools for AI assistants like Claude.
#' Requires the `mcptools` package.
#'
#' The server exposes these tools:
#' - `ac_deals` — Search and list deals
#' - `ac_deal` — Get a single deal by ID
#' - `ac_create_deal` — Create a new deal
#' - `ac_update_deal` — Update a deal
#' - `ac_contacts` — Search and list contacts
#' - `ac_contact` — Get a single contact by ID
#' - `ac_create_contact` — Create a new contact
#' - `ac_tags` — List all tags
#' - `ac_deal_custom_fields_wide` — Get custom fields for deals
#' - `ac_deal_pipelines` — List pipelines
#' - `ac_deal_stages` — List stages
#' - `ac_users` — List users
#' - `ac_automations` — List automations
#'
#' @return An MCP server object (started)
#' @export
#' @examples
#' \dontrun{
#' # Start the MCP server (after authenticating)
#' ac_auth_from_env()
#' ac_mcp_server()
#' }
ac_mcp_server <- function() {
  if (!requireNamespace("mcptools", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg mcptools} is required for MCP server support",
      "i" = 'Install it with: {.code install.packages("mcptools")}'
    ))
  }

  ac_check_auth()

  tools <- list(
    mcptools::tool(
      ac_deals,
      name = "ac_deals",
      description = "Search and list ActiveCampaign deals. Filter by status (0=open, 1=won, 2=lost), owner, pipeline, stage, or search string."
    ),
    mcptools::tool(
      ac_deal,
      name = "ac_deal",
      description = "Get a single ActiveCampaign deal by its ID. Returns all deal fields."
    ),
    mcptools::tool(
      ac_create_deal,
      name = "ac_create_deal",
      description = "Create a new deal in ActiveCampaign. Requires title; optional: value, currency, pipeline, stage, owner, contact."
    ),
    mcptools::tool(
      ac_update_deal,
      name = "ac_update_deal",
      description = "Update an existing deal. Pass the deal ID and any fields to change."
    ),
    mcptools::tool(
      ac_contacts,
      name = "ac_contacts",
      description = "Search and list ActiveCampaign contacts. Filter by email, search string, list, or tag."
    ),
    mcptools::tool(
      ac_contact,
      name = "ac_contact",
      description = "Get a single contact by ID."
    ),
    mcptools::tool(
      ac_create_contact,
      name = "ac_create_contact",
      description = "Create a new contact. Requires email; optional: first_name, last_name, phone."
    ),
    mcptools::tool(
      ac_tags,
      name = "ac_tags",
      description = "List all tags. Optional search parameter."
    ),
    mcptools::tool(
      ac_deal_custom_fields_wide,
      name = "ac_deal_custom_fields_wide",
      description = "Get all deal custom fields in wide format (one row per deal, one column per field)."
    ),
    mcptools::tool(
      ac_deal_pipelines,
      name = "ac_deal_pipelines",
      description = "List all deal pipelines."
    ),
    mcptools::tool(
      ac_deal_stages,
      name = "ac_deal_stages",
      description = "List all deal stages. Optional pipeline filter."
    ),
    mcptools::tool(
      ac_users,
      name = "ac_users",
      description = "List all ActiveCampaign users (team members)."
    ),
    mcptools::tool(
      ac_automations,
      name = "ac_automations",
      description = "List all automations."
    )
  )

  server <- mcptools::mcp_server(
    name = "activecampaignr",
    tools = tools
  )

  mcptools::start_server(server)
}
