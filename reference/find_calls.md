# Find all references to known functions within an expression

`find_calls()` recursively walks a parsed R expression and collects the
names of any functions that appear as either direct calls (`fun()`) or
bare name references (`fun`).

## Usage

``` r
find_calls(expr, known_names)
```

## Arguments

- expr:

  A parsed R expression.

- known_names:

  Character vector of function names to look for.

## Value

Character vector of unique matched function names.
