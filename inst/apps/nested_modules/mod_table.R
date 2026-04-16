# Table module — renders a summary table.
# Called by mod_display.

table_ui <- function(id) {
  ns <- NS(id)
  tableOutput(ns("tbl"))
}

table_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$tbl <- renderTable({
      head(data(), 10)
    })
  })
}
