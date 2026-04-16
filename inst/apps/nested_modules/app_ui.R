# Top-level UI — delegates entirely to display_ui.

app_ui <- function() {
  fluidPage(
    titlePanel("Nested Modules App"),
    display_ui("display1")
  )
}
