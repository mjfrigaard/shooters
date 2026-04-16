# A minimal Shiny app with no modules.
# Used to verify that ns_tree() works for plain ui/server apps.

library(shiny)

app_ui <- function() {
  fluidPage(
    titlePanel("No Modules App"),
    sidebarLayout(
      sidebarPanel(
        sliderInput("n", "Number of points", min = 10, max = 200, value = 50)
      ),
      mainPanel(
        plotOutput("scatter")
      )
    )
  )
}

app_server <- function(input, output, session) {
  plot_data <- make_data(input)
  output$scatter <- render_scatter(plot_data)
}

make_data <- function(input) {
  reactive({
    data.frame(
      x = rnorm(input$n),
      y = rnorm(input$n)
    )
  })
}

render_scatter <- function(data) {
  renderPlot({
    d <- data()
    plot(d$x, d$y, pch = 19, col = "steelblue",
         xlab = "x", ylab = "y", main = "Random scatter")
  })
}

launch <- function() {
  shinyApp(ui = app_ui(), server = app_server)
}
