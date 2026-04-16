# helpers ------------------------------------------------------------------

# Write named R source files into a temp directory and return the path.
make_app_dir <- function(...) {
  dir <- withr::local_tempdir(.local_envir = parent.frame())
  files <- list(...)
  for (nm in names(files)) {
    writeLines(files[[nm]], file.path(dir, nm))
  }
  dir
}

# .local_envir = parent.frame() binds the dir lifetime to the *test* frame,
# not to make_app_dir()'s own frame, so it isn't deleted too early.

# Capture the printed tree as a single string (newlines preserved).
capture_tree <- function(...) {
  paste(capture.output(ns_tree(...)), collapse = "\n")
}

# inst/apps paths ----------------------------------------------------------

apps_base <- function(name) {
  system.file("apps", name, package = "shooters")
}

# return value -------------------------------------------------------------

test_that("ns_tree() returns a list invisibly", {
  dir <- apps_base("no_modules")
  result <- withVisible(ns_tree(dir))
  expect_false(result$visible)
  expect_type(result$value, "list")
})

# tier 1: named launcher ---------------------------------------------------

test_that("tier 1 — root is the named launcher function", {
  out <- capture_tree(apps_base("no_modules"))
  expect_match(out, "\u2588\u2500launch")
})

test_that("tier 1 — no_modules tree contains app_ui and app_server", {
  out <- capture_tree(apps_base("no_modules"))
  expect_match(out, "app_ui")
  expect_match(out, "app_server")
})

test_that("tier 1 — no_modules tree contains helper functions", {
  out <- capture_tree(apps_base("no_modules"))
  expect_match(out, "make_data")
  expect_match(out, "render_scatter")
})

# single module ------------------------------------------------------------

test_that("single_module tree shows module ui and server", {
  out <- capture_tree(apps_base("single_module"))
  expect_match(out, "scatter_ui")
  expect_match(out, "scatter_server")
})

# nested modules -----------------------------------------------------------

test_that("nested_modules tree shows display module", {
  out <- capture_tree(apps_base("nested_modules"))
  expect_match(out, "display_ui")
  expect_match(out, "display_server")
})

test_that("nested_modules tree shows child plot and table modules", {
  out <- capture_tree(apps_base("nested_modules"))
  expect_match(out, "plot_ui")
  expect_match(out, "plot_server")
  expect_match(out, "table_ui")
  expect_match(out, "table_server")
})

# tier 2: ui/server co-roots -----------------------------------------------

test_that("tier 2 — virtual (app) root when no launcher", {
  dir <- make_app_dir(
    "app.R" = c(
      "ui <- fluidPage()",
      "server <- function(input, output, session) { helper() }",
      "helper <- function() NULL"
    )
  )
  out <- capture_tree(dir, ui_fun = "ui", server_fun = "server")
  expect_match(out, "\\(app\\)")
  expect_match(out, "server")
})

test_that("tier 2 — helper called from server appears in tree", {
  dir <- make_app_dir(
    "app.R" = c(
      "ui <- fluidPage()",
      "server <- function(input, output, session) { my_helper() }",
      "my_helper <- function() NULL"
    )
  )
  out <- capture_tree(dir, ui_fun = "ui", server_fun = "server")
  expect_match(out, "my_helper")
})

test_that("tier 2 — minimal inst app uses server as co-root", {
  out <- capture_tree(apps_base("minimal"), ui_fun = "ui", server_fun = "server")
  expect_match(out, "\\(app\\)")
  expect_match(out, "server")
})

# tier 3: all functions flat -----------------------------------------------

test_that("tier 3 — (app) root when no launcher or ui/server", {
  dir <- make_app_dir(
    "helpers.R" = c(
      "foo <- function() bar()",
      "bar <- function() NULL"
    )
  )
  out <- capture_tree(dir)
  expect_match(out, "\\(app\\)")
  expect_match(out, "foo")
  expect_match(out, "bar")
})

# empty / unparseable directory --------------------------------------------

test_that("empty directory returns (app) root with no children", {
  dir <- withr::local_tempdir()
  result <- ns_tree(dir)
  expect_equal(result$name, "(app)")
  expect_equal(result$children, list())
})

test_that("directory with only non-R files returns (app) root", {
  dir <- withr::local_tempdir()
  writeLines("# not R code", file.path(dir, "notes.txt"))
  result <- ns_tree(dir)
  expect_equal(result$name, "(app)")
})

test_that("unparseable R file is skipped without error", {
  dir <- make_app_dir("bad.R" = "this is {{{ not valid R")
  expect_no_error(ns_tree(dir))
})

# custom app_fun argument --------------------------------------------------

test_that("custom app_fun is used as root when present", {
  dir <- make_app_dir(
    "app.R" = c(
      "run_app <- function() { my_ui(); my_server() }",
      "my_ui     <- function() NULL",
      "my_server <- function() NULL"
    )
  )
  out <- capture_tree(dir, app_fun = "run_app")
  expect_match(out, "\u2588\u2500run_app")
  expect_match(out, "my_ui")
  expect_match(out, "my_server")
})
