# Entry point — sources all module files then launches the app.
# ns_tree() should be pointed at the directory containing these files.

library(shiny)

source("mod_plot.R")
source("mod_table.R")
source("mod_display.R")
source("app_ui.R")
source("app_server.R")

launch <- function() {
  shinyApp(ui = app_ui(), server = app_server)
}
