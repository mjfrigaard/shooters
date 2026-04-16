# Top-level server — delegates entirely to display_server.

app_server <- function(input, output, session) {
  display_server("display1")
}
