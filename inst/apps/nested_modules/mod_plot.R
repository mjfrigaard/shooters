# Plot module — renders a scatter plot.
# Called by mod_display.

plot_ui <- function(id) {
  ns <- NS(id)
  plotOutput(ns("plot"))
}

plot_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      d <- data()
      plot(d$x, d$y, pch = 19, col = "steelblue",
           xlab = "x", ylab = "y", main = "Scatter")
    })
  })
}
