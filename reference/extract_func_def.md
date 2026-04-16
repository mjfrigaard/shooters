# Extract function definitions from expression

`extract_func_def()` checks whether a parsed expression is a top-level
function assignment (e.g., `name <- function(...) { ... }`) and returns
the function name and body.

## Usage

``` r
extract_func_def(expr)
```

## Arguments

- expr:

  A parsed R expression.

## Value

A list with elements `name` (character) and `body` (expression), or
`NULL` if the expression is not a function definition.
