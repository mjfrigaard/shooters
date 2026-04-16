# Display module — owns the slider and delegates to plot + table modules.
# This is the "parent" module that nests plot_server and table_server.

display_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sliderInput(ns("n"), "Number of points", min = 10, max = 200, value = 50),
    plot_ui(ns("plot")),
    table_ui(ns("table"))
  )
}

display_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    data <- reactive({
      data.frame(x = rnorm(input$n), y = rnorm(input$n))
    })
    plot_server("plot", data)
    table_server("table", data)
  })
}
