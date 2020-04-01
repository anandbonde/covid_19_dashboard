library(data.table)
library(DT)
library(ggplot2)
library(plotly)
library(rworldmap)
library(scales)
library(shiny)
library(shinydashboard)
library(tidyverse)

################################## CONFIG.
WORKING_DIR <- "."
DATA_FILE_PATH <- file.path(WORKING_DIR, "full_daily_report.RData")
TIME_SERIES_FILE_PATH <-
    file.path(WORKING_DIR, "time_series_covid19_confirmed_global.csv")


################################## FUNCTIONS
plt_country_total_status <- function(data, country) {
    p <- data %>%
        filter(Country_Region == country) %>%
        ggplot(mapping = aes(x = reported_date)) +
        geom_line(aes(y = total_confirmed), col = "blue", size = 1.1) +
        geom_line(aes(y = total_recovered), col = "green", size = 1.1) +
        geom_line(aes(y = total_deaths), col = "red", size = 1.1, ) +
        theme(axis.text.x = element_text(angle = 90, size = 8)) +
        labs(x = "Reported on date", y = "Number of patients", title = country) +
        scale_x_date(date_breaks = "1 week", labels = date_format("%b-%d"))

    p
}

populate_country_drop_downs <-
    function(data, session, input) {
        list_of_countries <- sort(unique(data$Country_Region))

        drop_down_configs <- list()
        drop_down_configs[["country_select_1"]] <- "China"
        drop_down_configs[["country_select_2"]] <- "US"
        drop_down_configs[["country_select_3"]] <- "India"

        for (key in names(drop_down_configs)) {
            updateSelectInput(
                session,
                key,
                label = "",
                choices = list_of_countries,
                selected = drop_down_configs[key]
            )
        }

        observeEvent(input$country_select_1, {
            print("changed")
        })
        observeEvent(input$country_select_2, {
            print("changed")
        })
        observeEvent(input$country_select_3, {
            print("changed")
        })
    }

populate_world_map <- function(data, output) {
    last_column_name <- rev(names(data))[1]

    time_series_data <- data %>%
        mutate(
            popup_text = paste(
                `Country/Region`,
                "<br>",
                Long,
                ",",
                Lat,
                "<br>Confirmed today:",
                rev(data)[1]
            )
        )

    output$worldmap <- renderLeaflet({
        leaflet(options = leafletOptions(minZoom = 1, maxZoom = 18)) %>%
            addTiles() %>%
            # addMarkers(
            #     data = time_series_data,
            #     lng = ~ Long,
            #     lat = ~ Lat,
            #     popup = ~ popup_text,
            #     clusterOptions = markerClusterOptions(showCoverageOnHover = T)
            # )
            addCircleMarkers(
                data = time_series_data,
                lng = ~ Long,
                lat = ~ Lat,
                color = "red",
                popup = ~ popup_text,
                radius = 0.9
            )
    })
}

populate_world_map_highlight_countries <- function(data, output) {
    map_data <-
        data %>%
        group_by(Country_Region) %>%
        summarise(value = sum(Confirmed)) %>%
        mutate(country = Country_Region)

    spdf <-
        joinCountryData2Map(map_data, joinCode = "NAME", nameJoinColumn = "country")
    mapCountryData(spdf, nameColumnToPlot = "value", catMethod = "fixedWidth")

    output$worldmap <- renderPlot({
        mapParams <-
            mapPolys(
                spdf,
                nameColumnToPlot = 'value',
                mapRegion = 'world',
                missingCountryCol = 'dark grey',
                numCats = 100,
                # colourPalette=c('green4','green1','greenyellow','yellow','yellow2','orange','coral','red','red3','red4'),
                colourPalette = c('white', 'red', 'red3', 'red4'),
                # addLegend = TRUE,
                oceanCol = 'light blue'
            )
        mtext("[Grey: No Data Available]",
              side = 3,
              line = -1)
    })
}

populate_country_datatable <- function(data, output) {
    output$country_wise_counts_table <- DT::renderDataTable({
        dt <- data %>%
            filter(reported_date == max(reported_date)) %>%
            group_by(Country_Region) %>%
            summarise(
                Confirmed = sum(Confirmed),
                Recovered = sum(Recovered),
                Deaths = sum(Deaths)
            ) %>%
            na.omit() %>%
            arrange(desc(Confirmed))

        datatable(dt,
                  rownames = F,
                  options = list(scrollX = T)) %>%
            formatStyle(columns = c("Confirmed"), color = 'blue') %>%
            formatStyle(columns = c("Recovered"), color = 'green') %>%
            formatStyle(columns = c("Deaths"), color = 'red')
    })
}

populate_worldwide_status <-
    function(data, session, output) {
        totals <- data %>%
            filter(reported_date == max(reported_date))

        total_confirmed <- sum(totals$Confirmed)
        total_recovered <- sum(totals$Recovered)
        total_deaths <- sum(totals$Deaths)

        output$confirmed <- renderValueBox({
            valueBox(
                value = total_confirmed,
                subtitle = "confirmed cases",
                icon = icon("procedures"),
                color = "blue"
            )
        })

        output$recovered <- renderValueBox({
            valueBox(
                value = total_recovered,
                subtitle = "recovered cases",
                icon = icon("smile"),
                color = "green"
            )
        })

        output$deaths <- renderValueBox({
            valueBox(
                value = total_deaths,
                subtitle = "deaths",
                icon = icon("frown-open"),
                color = "red"
            )
        })
    }

populate_worldwide_growth_plot <- function(data, output) {
    output$worldwide_growth_plot <- renderPlot({
        worldwide_counts_per_day <-
            data %>% group_by(reported_date) %>%
            summarise(
                total_confirmed = sum(Confirmed),
                total_recovered = sum(Recovered),
                total_deaths = sum(Deaths)
            )

        p <- worldwide_counts_per_day %>%
            ggplot(mapping = aes(x = reported_date)) +
            geom_line(
                show.legend = T,
                aes(y = total_confirmed),
                col = "blue",
                size = 1.1
            ) +
            geom_line(
                show.legend = T,
                aes(y = total_recovered),
                col = "green",
                size = 1.1
            ) +
            geom_line(
                show.legend = T,
                aes(y = total_deaths),
                col = "red",
                size = 1.1
            ) +
            theme(axis.text.x = element_text(angle = 90, size = 8)) +
            labs(x = "Reported on date",
                 y = "Number of patients",
                 title = "Worldwide") +
            scale_x_date(date_breaks = "1 week", labels = date_format("%b-%d"))

        p
    })
}

populate_countrywise_growth_plots <- function(data, output) {
    country_wise_counts_per_day <-
        data %>%
        group_by(Country_Region, reported_date) %>%
        summarise(
            total_confirmed = sum(Confirmed),
            total_recovered = sum(Recovered),
            total_deaths = sum(Deaths)
        )

    output$china_growth_plot <- renderPlot({
        plt_country_total_status(country_wise_counts_per_day, "China")
    })

    output$us_growth_plot <- renderPlot({
        plt_country_total_status(country_wise_counts_per_day, "US")
    })

    output$india_growth_plot <- renderPlot({
        plt_country_total_status(country_wise_counts_per_day, "India")
    })
}

################################## SERVER
shinyServer(function(input, output, session) {
    load(file = DATA_FILE_PATH)

    # populate_country_drop_downs(data = full_daily_report, session = session, input = input)

    populate_worldwide_status(data = full_daily_report,
                              session = session,
                              output = output)

    populate_worldwide_growth_plot(data = full_daily_report, output = output)

    populate_countrywise_growth_plots(data = full_daily_report, output = output)

    populate_country_datatable(data = full_daily_report, output = output)

    time_series_data <- fread(TIME_SERIES_FILE_PATH)
    populate_world_map(data = time_series_data, output = output)
    # populate_world_map_highlight_countries(data = full_daily_report, output = output)
})
