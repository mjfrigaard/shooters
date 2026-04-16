# Getting started with shooters

`shooters` provides
[`ns_tree()`](https://mjfrigaard.github.io/shooters/reference/ns_tree.md),
a static-analysis tool that reads R source files from a directory,
builds a call graph of every function defined there, and prints a
plain-text tree showing how those functions call one another. It is
designed for Shiny apps — where understanding namespace structure
matters — but it works on any collection of R source files.

## How `ns_tree()` works

[`ns_tree()`](https://mjfrigaard.github.io/shooters/reference/ns_tree.md)
performs four steps on every `.R` file it finds in the target directory:

1.  **Parse** — [`parse()`](https://rdrr.io/r/base/parse.html) turns
    each file into an expression list.
2.  **Extract** —
    [`extract_func_def()`](https://mjfrigaard.github.io/shooters/reference/extract_func_def.md)
    identifies top-level function assignments
    (`name <- function(...) { ... }`).
3.  **Walk** —
    [`find_calls()`](https://mjfrigaard.github.io/shooters/reference/find_calls.md)
    recursively walks each function body and records references to other
    *known* (i.e. locally defined) functions.
4.  **Render** —
    [`build_tree()`](https://mjfrigaard.github.io/shooters/reference/build_tree.md)
    traverses the resulting call graph depth-first from a root node, and
    [`render_tree()`](https://mjfrigaard.github.io/shooters/reference/render_tree.md)
    formats the nested list as box-drawing ASCII art.

The root node is resolved with a three-tier fallback:

| Tier | Condition                           | Behaviour                                       |
|------|-------------------------------------|-------------------------------------------------|
| 1    | `app_fun` is defined                | Use it as the single tree root                  |
| 2    | `ui_fun` or `server_fun` is defined | Co-roots under a synthetic `(app)` node         |
| 3    | None of the above                   | All defined functions listed flat under `(app)` |

------------------------------------------------------------------------

## Example apps

`shooters` bundles four example apps in `inst/apps/` that cover the most
common Shiny structural patterns. The path to each app directory can be
retrieved with
[`system.file()`](https://rdrr.io/r/base/system.file.html).

``` r
apps <- system.file("apps", package = "shooters")
```

### 1. `minimal` — bare `ui` / `server`, no functions

The simplest possible Shiny app: `ui` is a plain R object (not a
function), `server` is a function defined at the top level, and both are
passed directly to `shinyApp()`. There is no launcher wrapper.

``` r
# inst/apps/minimal/app.R
ui <- fluidPage(
  titlePanel("Minimal App"),
  sidebarLayout(
    sidebarPanel(sliderInput("n", "Number of points", min = 10, max = 200, value = 50)),
    mainPanel(plotOutput("plot"))
  )
)

server <- function(input, output) {
  output$plot <- renderPlot({
    d <- data.frame(x = rnorm(input$n), y = rnorm(input$n))
    plot(d$x, d$y, pch = 19, col = "steelblue")
  })
}

shinyApp(ui, server)
```

Because there is no `launch()` function,
[`ns_tree()`](https://mjfrigaard.github.io/shooters/reference/ns_tree.md)
falls through to **Tier 2**: it looks for `ui_fun` and `server_fun` by
name. `ui` is not a function definition so
[`extract_func_def()`](https://mjfrigaard.github.io/shooters/reference/extract_func_def.md)
skips it; only `server` is captured. Pass the actual names used in the
file via the `ui_fun` / `server_fun` arguments:

``` r
ns_tree(
  file.path(apps, "minimal"),
  ui_fun     = "ui",
  server_fun = "server"
)
#> █─(app)
#> └─█─server
```

------------------------------------------------------------------------

### 2. `no_modules` — helper functions, no Shiny modules

The app is split into a `launch()` entry point, `app_ui()`,
`app_server()`, and two plain helper functions (`make_data()`,
`render_scatter()`). No `NS()` or `moduleServer()` are used.

``` r
# inst/apps/no_modules/app.R  (selected functions)
app_server <- function(input, output, session) {
  plot_data <- make_data(input)
  output$scatter <- render_scatter(plot_data)
}

make_data <- function(input) { ... }
render_scatter <- function(data) { ... }

launch <- function() {
  shinyApp(ui = app_ui(), server = app_server)
}
```

`launch()` is found immediately (**Tier 1**), so the tree is rooted
there. The helper calls inside `app_server` appear as its children:

``` r
ns_tree(file.path(apps, "no_modules"))
#> █─launch
#> ├─█─app_ui
#> └─█─app_server
#>   ├─█─make_data
#>   └─█─render_scatter
```

------------------------------------------------------------------------

### 3. `single_module` — one NS / moduleServer pair

A scatter-plot module (`scatter_ui` / `scatter_server`) is defined in
the same file and called from the app-level `app_ui()` / `app_server()`.

``` r
# inst/apps/single_module/app.R  (selected functions)
scatter_ui <- function(id) {
  ns <- NS(id)
  tagList(sliderInput(ns("n"), ...), plotOutput(ns("plot")))
}

scatter_server <- function(id) {
  moduleServer(id, function(input, output, session) { ... })
}

app_ui <- function() {
  fluidPage(titlePanel("Single Module App"), scatter_ui("scatter1"))
}

app_server <- function(input, output, session) {
  scatter_server("scatter1")
}

launch <- function() shinyApp(ui = app_ui(), server = app_server)
```

The tree shows the module pair nested one level below `app_ui` /
`app_server`:

``` r
ns_tree(file.path(apps, "single_module"))
#> █─launch
#> ├─█─app_ui
#> │ └─█─scatter_ui
#> └─█─app_server
#>   └─█─scatter_server
```

------------------------------------------------------------------------

### 4. `nested_modules` — modules calling other modules

The most realistic pattern: a `display` parent module owns a slider and
delegates rendering to two child modules (`plot`, `table`). Each module
pair lives in its own file; `app.R` sources them all.

    inst/apps/nested_modules/
    ├── app.R          # launch(), sources everything
    ├── app_ui.R       # app_ui()  → display_ui()
    ├── app_server.R   # app_server() → display_server()
    ├── mod_display.R  # display_ui(), display_server() → plot_*, table_*
    ├── mod_plot.R     # plot_ui(), plot_server()
    └── mod_table.R    # table_ui(), table_server()

[`ns_tree()`](https://mjfrigaard.github.io/shooters/reference/ns_tree.md)
reads *all* `.R` files in the directory so the full cross-file call
graph is assembled before the tree is built:

``` r
ns_tree(file.path(apps, "nested_modules"))
#> █─launch
#> ├─█─app_ui
#> │ └─█─display_ui
#> │   ├─█─plot_ui
#> │   └─█─table_ui
#> └─█─app_server
#>   └─█─display_server
#>     ├─█─plot_server
#>     └─█─table_server
```

The tree faithfully mirrors the physical module hierarchy: `display` is
the parent that bridges the app level to the `plot` and `table` leaf
modules.

------------------------------------------------------------------------

## Key arguments

``` r
ns_tree(
  path       = "R",          # directory to scan (default: "R/")
  app_fun    = "launch",     # Tier-1 root function name
  ui_fun     = "app_ui",     # Tier-2 UI co-root name
  server_fun = "app_server"  # Tier-2 server co-root name
)
```

Adjust `app_fun`, `ui_fun`, and `server_fun` to match whatever naming
convention the target app uses.

------------------------------------------------------------------------

## Running the demo apps

[`run_demo()`](https://mjfrigaard.github.io/shooters/reference/run_demo.md)
launches any of the four example apps interactively:

``` r
run_demo()                    # nested_modules (default)
run_demo("single_module")
run_demo("no_modules")
run_demo("minimal")
```
