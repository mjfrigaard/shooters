#' Render Shiny module tree as plain-text ASCII art
#'
#' `render_tree()` takes a nested tree structure (as produced by
#' [build_tree()]) and returns a character vector of lines using
#' box-drawing characters in the style of
#' [`lobstr::ast()`](https://lobstr.r-lib.org/reference/ast.html).
#'
#' @param tree A nested list with `name` and `children` elements.
#' @param prefix Character scalar; the current indentation prefix
#'   (used internally during recursion).
#' @param is_last Logical; whether this node is the last sibling.
#' @param is_root Logical; whether this node is the root.
#'
#' @return Character vector of formatted lines.
#'
#' @keywords internal
#'
render_tree <- function(tree, prefix = "", is_last = TRUE, is_root = TRUE) {
  lines <- character(0)

  if (is_root) {
    lines <- c(lines, paste0("\u2588\u2500", tree$name))
    child_prefix <- ""
  } else {
    connector <- if (is_last) "\u2514\u2500" else "\u251C\u2500"
    lines <- c(lines, paste0(prefix, connector, "\u2588\u2500", tree$name))
    child_prefix <- paste0(prefix, if (is_last) "  " else "\u2502 ")
  }

  n <- length(tree$children)
  if (n > 0) {
    for (i in seq_along(tree$children)) {
      child <- tree$children[[i]]
      child_is_last <- (i == n)
      lines <- c(lines, render_tree(child, child_prefix, child_is_last, is_root = FALSE))
    }
  }

  lines
}
