# Pipeline Analysis with officer

## Overview

This vignette shows how to build a PowerPoint pipeline report using
activecampaignr, [officer](https://davidgohel.github.io/officer/), and
[mschart](https://ardata-fr.github.io/mschart/).

**Why mschart?** When you embed a ggplot into PowerPoint via
`dml(ggobj = ...)`, the chart is a static image. Recipients can’t edit
the data, change colours, or resize without losing quality. `mschart`
creates native Office charts: fully editable, with the data table
embedded in the `.pptx` file. Your audience can restyle the chart in
PowerPoint without needing R.

## Setup

``` r

library(activecampaignr)
library(dplyr)
library(officer)
library(mschart)

ac_auth_from_env()
```

## Fetch Data

Use
[`ac_deals_full()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_deals_full.md)
to get deals pre-joined with stage names, pipeline names, and owner
names:

``` r

deals <- ac_deals_full()
```

## Prepare Analysis Data

``` r

# Won deals with day-of-week and velocity
won <- deals |>
  filter(status == "1") |>
  mutate(
    dow = weekdays(mdate),
    dow = factor(dow, levels = c(
      "Monday", "Tuesday", "Wednesday",
      "Thursday", "Friday", "Saturday", "Sunday"
    )),
    days_in_pipeline = as.numeric(difftime(mdate, cdate, units = "days"))
  )
```

## Chart 1: Deals Won by Day of Week (mschart bar chart)

``` r

dow_data <- won |>
  count(dow, name = "deals") |>
  filter(!is.na(dow))

chart_dow <- ms_barchart(
  data = dow_data,
  x = "dow",
  y = "deals"
) |>
  chart_settings(dir = "vertical", grouping = "clustered") |>
  chart_labels(
    title = "Deals Won by Day of Week",
    xlab = NULL,
    ylab = "Deals"
  ) |>
  chart_data_fill(values = rep("#356AE6", 7)) |>
  chart_theme(
    grid_major_line = fp_border(style = "none"),
    legend_position = "n"
  )
```

## Chart 2: Pipeline Velocity by Stage (mschart bar chart)

``` r

velocity_data <- won |>
  filter(!is.na(stage_title)) |>
  group_by(stage = stage_title) |>
  summarise(
    median_days = round(median(days_in_pipeline, na.rm = TRUE), 1),
    .groups = "drop"
  ) |>
  arrange(median_days)

chart_velocity <- ms_barchart(
  data = velocity_data,
  x = "stage",
  y = "median_days"
) |>
  chart_settings(dir = "horizontal", grouping = "clustered") |>
  chart_labels(
    title = "Pipeline Velocity (Median Days by Stage)",
    xlab = NULL,
    ylab = "Days"
  ) |>
  chart_data_fill(values = rep("#1A3A7A", nrow(velocity_data))) |>
  chart_theme(
    grid_major_line = fp_border(style = "none"),
    legend_position = "n"
  )
```

## Chart 3: Win Rate by Owner (mschart bar chart)

``` r

owner_data <- won |>
  filter(!is.na(owner_name)) |>
  group_by(owner = owner_name) |>
  summarise(
    total = n(),
    .groups = "drop"
  ) |>
  # Join back to get all deals (not just won) for win rate
  left_join(
    deals |>
      filter(!is.na(owner_name)) |>
      count(owner = owner_name, name = "all_deals"),
    by = "owner"
  ) |>
  mutate(win_rate = round(total / all_deals * 100, 1)) |>
  filter(all_deals >= 10) |>
  arrange(desc(win_rate))

chart_owner <- ms_barchart(
  data = owner_data,
  x = "owner",
  y = "win_rate"
) |>
  chart_settings(dir = "horizontal", grouping = "clustered") |>
  chart_labels(
    title = "Win Rate by Owner (%)",
    xlab = NULL,
    ylab = "Win Rate (%)"
  ) |>
  chart_data_fill(values = rep("#16a34a", nrow(owner_data))) |>
  chart_theme(
    grid_major_line = fp_border(style = "none"),
    legend_position = "n"
  )
```

## Chart 4: Monthly Deal Flow (mschart line chart)

``` r

monthly_flow <- deals |>
  mutate(month = format(cdate, "%Y-%m")) |>
  group_by(month) |>
  summarise(
    created = n(),
    won = sum(status == "1", na.rm = TRUE),
    lost = sum(status == "2", na.rm = TRUE),
    .groups = "drop"
  ) |>
  filter(!is.na(month)) |>
  tidyr::pivot_longer(
    cols = c(created, won, lost),
    names_to = "metric",
    values_to = "count"
  )

chart_flow <- ms_linechart(
  data = monthly_flow,
  x = "month",
  y = "count",
  group = "metric"
) |>
  chart_labels(
    title = "Monthly Deal Flow",
    xlab = NULL,
    ylab = "Deals"
  ) |>
  chart_data_stroke(
    values = c(created = "#356AE6", won = "#16a34a", lost = "#dc2626")
  ) |>
  chart_data_size(values = c(created = 2, won = 2, lost = 2)) |>
  chart_theme(legend_position = "b")
```

## Assemble the PowerPoint

``` r

pptx <- read_pptx() |>
  # Title slide
  add_slide(layout = "Title Slide") |>
  ph_with(
    "Pipeline Analysis Report",
    location = ph_location_type("ctrTitle")
  ) |>
  ph_with(
    format(Sys.Date(), "%d %b %Y"),
    location = ph_location_type("subTitle")
  ) |>

  # Slide 1: Day of week
  add_slide(layout = "Title and Content") |>
  ph_with(
    "Deals Won by Day of Week",
    location = ph_location_type("title")
  ) |>
  ph_with(
    chart_dow,
    location = ph_location_type("body")
  ) |>

  # Slide 2: Pipeline velocity
  add_slide(layout = "Title and Content") |>
  ph_with(
    "Pipeline Velocity",
    location = ph_location_type("title")
  ) |>
  ph_with(
    chart_velocity,
    location = ph_location_type("body")
  ) |>

  # Slide 3: Win rate by owner
  add_slide(layout = "Title and Content") |>
  ph_with(
    "Win Rate by Owner",
    location = ph_location_type("title")
  ) |>
  ph_with(
    chart_owner,
    location = ph_location_type("body")
  ) |>

  # Slide 4: Monthly deal flow
  add_slide(layout = "Title and Content") |>
  ph_with(
    "Monthly Deal Flow",
    location = ph_location_type("title")
  ) |>
  ph_with(
    chart_flow,
    location = ph_location_type("body")
  ) |>

  # Slide 5: Summary table
  add_slide(layout = "Title and Content") |>
  ph_with(
    "Summary",
    location = ph_location_type("title")
  ) |>
  ph_with(
    data.frame(
      Metric = c("Total deals", "Won", "Lost", "Open",
                  "Win rate", "Median velocity"),
      Value = c(
        nrow(deals),
        sum(deals$status == "1", na.rm = TRUE),
        sum(deals$status == "2", na.rm = TRUE),
        sum(deals$status == "0", na.rm = TRUE),
        paste0(round(mean(deals$status == "1", na.rm = TRUE) * 100, 1), "%"),
        paste(round(median(won$days_in_pipeline, na.rm = TRUE), 0), "days")
      )
    ),
    location = ph_location_type("body")
  )

print(pptx, target = "pipeline-report.pptx")
```

The resulting file is a standard `.pptx` that opens in PowerPoint,
Keynote, or Google Slides. All four charts are native Office charts:
double-click any chart in PowerPoint to edit the underlying data, change
colours, or adjust formatting.

## Mixing mschart and ggplot

You can use both in the same report. Use `mschart` when you want
editable charts, and `dml(ggobj = ...)` when you need ggplot-specific
features (facets, custom geoms, annotations):

``` r

library(ggplot2)

p_custom <- won |>
  ggplot(aes(days_in_pipeline)) +
  geom_histogram(binwidth = 7, fill = "#356AE6", colour = "white") +
  geom_vline(
    xintercept = median(won$days_in_pipeline, na.rm = TRUE),
    linetype = "dashed", colour = "red"
  ) +
  annotate(
    "text",
    x = median(won$days_in_pipeline, na.rm = TRUE) + 5,
    y = Inf, vjust = 2, hjust = 0,
    label = paste("Median:", round(median(won$days_in_pipeline, na.rm = TRUE)), "days"),
    colour = "red"
  ) +
  labs(title = "Velocity Distribution", x = "Days to Close", y = "Deals") +
  theme_minimal()

# Add as a ggplot image slide (not editable, but supports annotations)
pptx <- pptx |>
  add_slide(layout = "Title and Content") |>
  ph_with(
    "Velocity Distribution (ggplot)",
    location = ph_location_type("title")
  ) |>
  ph_with(
    dml(ggobj = p_custom),
    location = ph_location_type("body")
  )

print(pptx, target = "pipeline-report.pptx")
```

## When to Use Which

| Approach | Editable in PPT? | Best for |
|----|----|----|
| `mschart` (ms_barchart, ms_linechart, etc.) | Yes | Bar, line, pie, scatter charts that stakeholders may want to restyle |
| `dml(ggobj = ...)` | No (image) | Complex ggplot charts with facets, annotations, custom geoms |
| `ph_with(data.frame(...))` | Yes (table) | Summary statistics, KPI tables |
