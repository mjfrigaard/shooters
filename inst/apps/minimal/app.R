# A minimal Shiny app — no wrapper functions, no modules.
# ui and server are passed directly to shinyApp().
# Used to verify that ns_tree() handles apps with no call graph root.

library(shiny)

ui <- fluidPage(
  titlePanel("Minimal App"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Number of points", min = 10, max = 200, value = 50)
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output) {
  output$plot <- renderPlot({
    d <- data.frame(x = rnorm(input$n), y = rnorm(input$n))
    plot(d$x, d$y, pch = 19, col = "steelblue",
         xlab = "x", ylab = "y", main = "Random scatter")
  })
}

shinyApp(ui, server)
