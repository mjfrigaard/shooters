#' Build a nested tree from a call graph
#'
#' `build_tree()` performs a depth-first traversal of a call graph
#' starting from a given node, producing a nested list structure
#' suitable for rendering.
#'
#' @param node Character scalar; the root function name.
#' @param call_graph Named list where each element is a character vector of
#'   function names called by that function.
#' @param visited Character vector of already-visited node names (used
#'   internally to prevent cycles).
#'
#' @return A nested list with elements `name` (character) and `children`
#'   (list of similar structures).
#'
#' @keywords internal
#'
build_tree <- function(node, call_graph, visited = character(0)) {
  children_names <- call_graph[[node]]
  children_names <- setdiff(children_names, c(visited, node))

  children <- list()
  for (child in children_names) {
    children[[child]] <- build_tree(child, call_graph, visited = c(visited, node))
  }

  list(name = node, children = children)
}
