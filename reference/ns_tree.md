# Display a plain-text namespace tree for a Shiny app

`ns_tree()` statically parses all R source files in a directory, builds
a call graph of every function defined there, and prints a plain-text
tree showing how functions call one another. Functions that use
[`shiny::NS()`](https://rdrr.io/pkg/shiny/man/NS.html) or
[`shiny::moduleServer()`](https://rdrr.io/pkg/shiny/man/moduleServer.html)
are identified as Shiny modules, but their presence is not required —
`ns_tree()` works for any collection of R source files.

## Usage

``` r
ns_tree(
  path = "R",
  app_fun = "launch",
  ui_fun = "app_ui",
  server_fun = "app_server"
)
```

## Arguments

- path:

  Character scalar; path to the directory containing R source files.
  Defaults to `"R"`.

- app_fun:

  Character scalar; name of the top-level app launch function used as
  the tree root. Defaults to `"launch"`.

- ui_fun:

  Character scalar; name of the UI function. Defaults to `"app_ui"`.

- server_fun:

  Character scalar; name of the server function. Defaults to
  `"app_server"`.

## Value

Invisibly returns the nested tree structure (a list). The tree is
printed to the console as a side effect.

## Details

The tree root is resolved with a three-tier fallback:

1.  `app_fun` — a named launcher function (e.g. `launch()`).

2.  `ui_fun` + `server_fun` — displayed as co-roots under `(app)` when
    no launcher is found (e.g. bare `ui` / `server` objects).

3.  All defined functions listed flat under `(app)` when neither of the
    above is found.

## Examples

``` r
# Locate the bundled demo apps
apps <- system.file("apps", package = "shooters")

# Bare ui/server — no wrapper functions, no modules
ns_tree(file.path(apps, "minimal"), ui_fun = "ui", server_fun = "server")
#> █─(app)
#> └─█─server 

# Helper functions, no Shiny modules
ns_tree(file.path(apps, "no_modules"))
#> █─launch
#> ├─█─app_ui
#> └─█─app_server
#>   ├─█─make_data
#>   └─█─render_scatter 

# One NS / moduleServer pair
ns_tree(file.path(apps, "single_module"))
#> █─launch
#> ├─█─app_ui
#> │ └─█─scatter_ui
#> └─█─app_server
#>   └─█─scatter_server 

# Modules calling other modules (multi-file)
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
