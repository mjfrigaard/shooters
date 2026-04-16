# Check if expression contains Shiny module identifiers

`uses_ns()` recursively walks a parsed R expression to detect calls to
[`shiny::NS()`](https://rdrr.io/pkg/shiny/man/NS.html) or
[`shiny::moduleServer()`](https://rdrr.io/pkg/shiny/man/moduleServer.html),
which are reliable indicators that a function is a Shiny module.

## Usage

``` r
uses_ns(expr)
```

## Arguments

- expr:

  A parsed R expression.

## Value

Logical scalar; `TRUE` if a call to `NS()` or `moduleServer()` is found.
