# shooters

`shooters` provides static-analysis utilities for Shiny applications.
The flagship function,
[`ns_tree()`](https://mjfrigaard.github.io/shooters/reference/ns_tree.md),
parses R source files in a directory and prints a plain-text call tree
showing how functions relate to one another — with no need to run the
app.

## Installation

``` r
# install.packages("pak")
pak::pak("mjfrigaard/shooters")
```

## Usage

Point
[`ns_tree()`](https://mjfrigaard.github.io/shooters/reference/ns_tree.md)
at any directory that contains R source files:

``` r
ns_tree("R")
```

### Example apps

`shooters` bundles four example apps that cover the most common Shiny
structural patterns.

``` r
apps <- system.file("apps", package = "shooters")
```

#### `minimal` — bare `ui` / `server`

No wrapper functions and no modules. `ui` is a plain object; `server` is
the only defined function. Use `ui_fun` / `server_fun` to tell
[`ns_tree()`](https://mjfrigaard.github.io/shooters/reference/ns_tree.md)
what to look for:

``` r
ns_tree(file.path(apps, "minimal"), ui_fun = "ui", server_fun = "server")
#> █─(app)
#> └─█─server
```

#### `no_modules` — helper functions, no modules

A `launch()` entry point calls `app_ui()` and `app_server()`. The server
delegates to two plain helper functions:

``` r
ns_tree(file.path(apps, "no_modules"))
#> █─launch
#> ├─█─app_ui
#> └─█─app_server
#>   ├─█─make_data
#>   └─█─render_scatter
```

#### `single_module` — one NS / moduleServer pair

A scatter-plot module (`scatter_ui` / `scatter_server`) is nested inside
the app-level UI and server:

``` r
ns_tree(file.path(apps, "single_module"))
#> █─launch
#> ├─█─app_ui
#> │ └─█─scatter_ui
#> └─█─app_server
#>   └─█─scatter_server
```

#### `nested_modules` — modules calling other modules

A `display` parent module delegates to `plot` and `table` child modules,
spread across multiple files:

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

## How it works

[`ns_tree()`](https://mjfrigaard.github.io/shooters/reference/ns_tree.md)
operates in four steps:

1.  **Parse** every `.R` file in the target directory with
    [`parse()`](https://rdrr.io/r/base/parse.html).
2.  **Extract** top-level function definitions
    (`name <- function(...)`).
3.  **Walk** each function body to find references to other locally
    defined functions, building a call graph.
4.  **Render** the call graph as a depth-first ASCII tree, starting from
    the app root.

The root is resolved with a three-tier fallback:

| Tier | Condition                                 | Root used                           |
|------|-------------------------------------------|-------------------------------------|
| 1    | `app_fun` (default `"launch"`) is defined | That function                       |
| 2    | `ui_fun` or `server_fun` is defined       | Co-roots under `(app)`              |
| 3    | None of the above                         | All defined functions under `(app)` |

## Demo apps

Run any of the bundled example apps interactively:

``` r
run_demo()                    # nested_modules (default)
run_demo("single_module")
run_demo("no_modules")
run_demo("minimal")
```
