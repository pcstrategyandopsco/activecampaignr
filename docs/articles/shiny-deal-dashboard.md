# Interactive Deal Dashboard with Shiny

## Overview

This vignette shows how to build an interactive deal explorer using
activecampaignr and Shiny. A runnable example is included at
`inst/shiny-examples/deal-dashboard/`.

## Run the Example

``` r

library(shiny)
runApp(system.file("shiny-examples/deal-dashboard", package = "activecampaignr"))
```

## Build Your Own

``` r

library(shiny)
library(activecampaignr)
library(dplyr)
library(DT)

# Authenticate before launching
ac_auth_from_env()

ui <- fluidPage(
  titlePanel("ActiveCampaign Deal Explorer"),

  sidebarLayout(
    sidebarPanel(
      selectInput("status", "Status",
                  choices = c("All" = "", "Open" = "0", "Won" = "1", "Lost" = "2")),
      dateRangeInput("dates", "Modified Date Range",
                     start = Sys.Date() - 90, end = Sys.Date()),
      actionButton("refresh", "Refresh Data", class = "btn-primary"),
      hr(),
      verbatimTextOutput("summary")
    ),

    mainPanel(
      DT::dataTableOutput("deals_table")
    )
  )
)

server <- function(input, output, session) {
  deals_data <- reactiveVal(tibble())

  observeEvent(input$refresh, {
    withProgress(message = "Fetching deals...", {
      result <- ac_sync_deals(force = TRUE)
      deals_data(result$deals)
    })
  }, ignoreNULL = FALSE)

  filtered <- reactive({
    df <- deals_data()
    if (nrow(df) == 0) return(df)

    if (nzchar(input$status)) {
      df <- filter(df, status == input$status)
    }

    if (!is.null(input$dates)) {
      df <- filter(df,
                   as.Date(mdate) >= input$dates[1],
                   as.Date(mdate) <= input$dates[2])
    }

    df
  })

  output$deals_table <- DT::renderDataTable({
    df <- filtered()
    if (nrow(df) == 0) return(DT::datatable(tibble(Message = "No deals found")))

    display <- df |>
      select(any_of(c("id", "title", "value", "status", "owner",
                       "cdate", "mdate")))

    DT::datatable(display, options = list(pageLength = 25, scrollX = TRUE))
  })

  output$summary <- renderText({
    df <- filtered()
    paste0(
      "Total: ", nrow(df), " deals\n",
      "Total value: $", format(sum(as.numeric(df$value %||% 0), na.rm = TRUE) / 100,
                                big.mark = ","), "\n",
      "Date range: ", min(df$mdate, na.rm = TRUE), " to ",
      max(df$mdate, na.rm = TRUE)
    )
  })
}

shinyApp(ui, server)
```
