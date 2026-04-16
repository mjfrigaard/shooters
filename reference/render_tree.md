# Render Shiny module tree as plain-text ASCII art

`render_tree()` takes a nested tree structure (as produced by
[`build_tree()`](https://mjfrigaard.github.io/shooters/reference/build_tree.md))
and returns a character vector of lines using box-drawing characters in
the style of
[`lobstr::ast()`](https://lobstr.r-lib.org/reference/ast.html).

## Usage

``` r
render_tree(tree, prefix = "", is_last = TRUE, is_root = TRUE)
```

## Arguments

- tree:

  A nested list with `name` and `children` elements.

- prefix:

  Character scalar; the current indentation prefix (used internally
  during recursion).

- is_last:

  Logical; whether this node is the last sibling.

- is_root:

  Logical; whether this node is the root.

## Value

Character vector of formatted lines.
