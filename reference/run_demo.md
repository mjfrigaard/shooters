# Launch a demo Shiny app

Launches one of the example Shiny applications bundled with `shooters`
in `inst/apps/`. Each app demonstrates a different structural pattern
for use with
[`ns_tree()`](https://mjfrigaard.github.io/shooters/reference/ns_tree.md):

## Usage

``` r
run_demo(which = c("nested_modules", "single_module", "no_modules", "minimal"))
```

## Arguments

- which:

  Character scalar; which demo app to launch. One of `"minimal"`,
  `"no_modules"`, `"single_module"`, or `"nested_modules"` (default).

## Value

Called for its side effect (launches a Shiny app). Returns invisibly.

## Details

- `"minimal"` — bare `ui` / `server` objects passed directly to
  `shinyApp()`, no wrapper functions and no modules.

- `"no_modules"` — helper functions wrapping `ui` and `server`, no Shiny
  modules.

- `"single_module"` — one module pair (`NS` + `moduleServer`).

- `"nested_modules"` — modules that call other modules, spread across
  multiple files.

## Examples

``` r
if (FALSE) { # \dontrun{
run_demo()                   # nested_modules (default)
run_demo("single_module")
run_demo("no_modules")
run_demo("minimal")
} # }
```
