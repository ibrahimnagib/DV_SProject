#ui.R

require(shiny)
require(shinydashboard)
require(leaflet)

dashboardPage(
  dashboardHeader(
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Crosstab", tabName = "crosstab", icon = icon("dashboard")),
      menuItem("Barchart", tabName = "barchart", icon = icon("th")),
      menuItem("Blending", tabName = "blending", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "crosstab",
              #actionButton(inputId = "light", label = "Light"),
              #actionButton(inputId = "dark", label = "Dark"),
              sliderInput("KPI1", "Rated_Horsepower_value:", 
                          min = 1, max = 800,  value = 800),
              textInput(inputId = "title", 
                        label = "Crosstab Title",
                        value = "Rated Horse Power"),
              actionButton(inputId = "clicks1",  label = "Click me"),
              plotOutput("distPlot1")
      )#,
      
      # Second tab content
      #tabItem(tabName = "barchart",
      #        actionButton(inputId = "clicks2",  label = "Click me"),
      #        plotOutput("distPlot2")
      #),
      
      # Third tab content
      #tabItem(tabName = "blending",
      #        actionButton(inputId = "clicks3",  label = "Click me"),
      #        plotOutput("distPlot3")
      #)
    )
  )
)
