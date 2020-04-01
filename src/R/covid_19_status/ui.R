library("DT")
library("leaflet")
library("plotly")
library("shinydashboard")

dashboardPage(
    dashboardHeader(title = "Covid 19 Worldwide"),
    dashboardSidebar(disable = T),
    dashboardBody(
        fluidRow(column(
            12,
            align = "center",
            HTML(
                '<h3>#stayhome, #washhands, #spreadtheword</h3>'
            )
        )),
        fluidRow(column(
            12,
            align = "center",
            HTML(
                '<h5>See more of my work @ <a target="popup" href="https://curiotiveme.wordpress.com/">https://curiotiveme.wordpress.com/</a></h5>'
            )
        )),
        fluidRow(
            HTML(
                '<marquee behavior="scroll" direction="left">Data credits: Johns Hopkins University (updated every hour from the data source)</marquee>'
            )
        ),
        fluidRow(
            valueBoxOutput("confirmed"),
            valueBoxOutput("recovered"),
            valueBoxOutput("deaths")
        ),
        fluidRow(
            column(3, plotOutput("worldwide_growth_plot")),
            
            column(3, align = "center", plotOutput("china_growth_plot")),
            column(3, align = "center", plotOutput("us_growth_plot")),
            column(3, align = "center", plotOutput("india_growth_plot"))
        ),
        fluidRow(DTOutput("country_wise_counts_table")),
        fluidRow(
            HTML(
                '<marquee behavior="scroll" direction="left">Showing data at county and major city level.</marquee>'
            )
        ),
        fluidRow(leafletOutput("worldmap"))
    )
)
