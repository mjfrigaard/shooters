# A Shiny app with one module (scatter plot).
# Used to verify that ns_tree() detects a single NS / moduleServer pair.

library(shiny)

# -- module -----------------------------------------------------------------

scatter_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sliderInput(ns("n"), "Number of points", min = 10, max = 200, value = 50),
    plotOutput(ns("plot"))
  )
}

scatter_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      d <- data.frame(x = rnorm(input$n), y = rnorm(input$n))
      plot(d$x, d$y, pch = 19, col = "steelblue",
           xlab = "x", ylab = "y", main = "Random scatter")
    })
  })
}

# -- app --------------------------------------------------------------------

app_ui <- function() {
  fluidPage(
    titlePanel("Single Module App"),
    scatter_ui("scatter1")
  )
}

app_server <- function(input, output, session) {
  scatter_server("scatter1")
}

launch <- function() {
  shinyApp(ui = app_ui(), server = app_server)
}
