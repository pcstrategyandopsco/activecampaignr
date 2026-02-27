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
      width = 3,
      selectInput("status", "Deal Status",
                  choices = c("All" = "", "Open" = "0",
                              "Won" = "1", "Lost" = "2")),
      textInput("search", "Search Deals", placeholder = "Deal title..."),
      dateRangeInput("dates", "Modified Date Range",
                     start = Sys.Date() - 90, end = Sys.Date()),
      hr(),
      actionButton("refresh", "Refresh Data", class = "btn-primary",
                   icon = icon("refresh")),
      actionButton("force_refresh", "Force Full Sync",
                   class = "btn-warning", icon = icon("sync")),
      hr(),
      h4("Summary"),
      verbatimTextOutput("summary"),
      hr(),
      h4("Cache Status"),
      tableOutput("cache_info")
    ),

    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel("Deals", DT::dataTableOutput("deals_table")),
        tabPanel("Pipeline", plotOutput("pipeline_plot", height = "500px")),
        tabPanel("Timeline", plotOutput("timeline_plot", height = "500px"))
      )
    )
  )
)

server <- function(input, output, session) {
  deals_data <- reactiveVal(tibble::tibble())

  # Initial load
  observe({
    result <- ac_sync_deals()
    deals_data(result$deals)
  })

  observeEvent(input$refresh, {
    withProgress(message = "Syncing deals...", {
      result <- ac_sync_deals()
      deals_data(result$deals)
    })
  })

  observeEvent(input$force_refresh, {
    withProgress(message = "Full sync...", {
      result <- ac_sync_deals(force = TRUE)
      deals_data(result$deals)
    })
  })

  filtered <- reactive({
    df <- deals_data()
    if (nrow(df) == 0) return(df)

    if (nzchar(input$status)) {
      df <- dplyr::filter(df, .data$status == .env$input$status)
    }

    if (nzchar(input$search)) {
      pattern <- tolower(input$search)
      df <- dplyr::filter(df, grepl(pattern, tolower(.data$title)))
    }

    if (!is.null(input$dates)) {
      df <- dplyr::filter(
        df,
        as.Date(.data$mdate) >= input$dates[1],
        as.Date(.data$mdate) <= input$dates[2]
      )
    }

    df
  })

  output$deals_table <- DT::renderDataTable({
    df <- filtered()
    if (nrow(df) == 0) {
      return(DT::datatable(tibble::tibble(Message = "No deals found")))
    }

    display <- df |>
      dplyr::select(dplyr::any_of(c(
        "id", "title", "value", "status", "owner", "cdate", "mdate"
      )))

    DT::datatable(display,
                  options = list(pageLength = 25, scrollX = TRUE),
                  filter = "top")
  })

  output$summary <- renderText({
    df <- filtered()
    if (nrow(df) == 0) return("No deals to display")
    val <- sum(as.numeric(df$value %||% 0), na.rm = TRUE) / 100
    paste0(
      "Deals: ", nrow(df), "\n",
      "Total value: $", format(val, big.mark = ",", nsmall = 0)
    )
  })

  output$cache_info <- renderTable({
    input$refresh
    input$force_refresh
    tryCatch(ac_cache_status() |> dplyr::select(-"path"), error = function(e) NULL)
  })

  output$pipeline_plot <- renderPlot({
    df <- filtered()
    if (nrow(df) == 0) return(NULL)
    if (!"stage" %in% names(df)) return(NULL)

    df |>
      dplyr::count(.data$stage) |>
      ggplot2::ggplot(ggplot2::aes(x = reorder(.data$stage, .data$n),
                                    y = .data$n)) +
      ggplot2::geom_col(fill = "#2563eb") +
      ggplot2::coord_flip() +
      ggplot2::labs(title = "Deals by Stage", x = "Stage", y = "Count") +
      ggplot2::theme_minimal(base_size = 14)
  })

  output$timeline_plot <- renderPlot({
    df <- filtered()
    if (nrow(df) == 0 || !"mdate" %in% names(df)) return(NULL)

    df |>
      dplyr::mutate(month = format(.data$mdate, "%Y-%m")) |>
      dplyr::count(.data$month) |>
      ggplot2::ggplot(ggplot2::aes(x = .data$month, y = .data$n)) +
      ggplot2::geom_col(fill = "#16a34a") +
      ggplot2::labs(title = "Deals by Month", x = NULL, y = "Count") +
      ggplot2::theme_minimal(base_size = 14) +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
  })
}

shinyApp(ui, server)
