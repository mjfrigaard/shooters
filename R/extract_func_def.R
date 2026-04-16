#' Extract function definitions from expression
#'
#' `extract_func_def()` checks whether a parsed expression is a top-level
#' function assignment (e.g., `name <- function(...) { ... }`) and
#' returns the function name and body.
#'
#' @param expr A parsed R expression.
#'
#' @return A list with elements `name` (character) and `body` (expression),
#'   or `NULL` if the expression is not a function definition.
#'
#' @keywords internal
#'
extract_func_def <- function(expr) {
  if (!is.call(expr)) return(NULL)

  op <- as.character(expr[[1]])

  if (op %in% c("<-", "=", "assign") && length(expr) == 3) {
    name <- if (op == "assign") {
      if (is.character(expr[[2]])) expr[[2]] else return(NULL)
    } else {
      if (is.name(expr[[2]])) as.character(expr[[2]]) else return(NULL)
    }

    val <- expr[[3]]

    if (is.call(val) && as.character(val[[1]]) == "function") {
      return(list(name = name, body = val))
    }
  }

  NULL
}
