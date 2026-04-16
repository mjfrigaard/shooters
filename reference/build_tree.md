# Build a nested tree from a call graph

`build_tree()` performs a depth-first traversal of a call graph starting
from a given node, producing a nested list structure suitable for
rendering.

## Usage

``` r
build_tree(node, call_graph, visited = character(0))
```

## Arguments

- node:

  Character scalar; the root function name.

- call_graph:

  Named list where each element is a character vector of function names
  called by that function.

- visited:

  Character vector of already-visited node names (used internally to
  prevent cycles).

## Value

A nested list with elements `name` (character) and `children` (list of
similar structures).
