#' Find all references to known functions within an expression
#'
#' `find_calls()` recursively walks a parsed R expression and collects
#' the names of any functions that appear as either direct calls
#' (`fun()`) or bare name references (`fun`).
#'
#' @param expr A parsed R expression.
#' @param known_names Character vector of function names to look for.
#'
#' @return Character vector of unique matched function names.
#'
#' @keywords internal
#'
find_calls <- function(expr, known_names) {
  found <- character(0)
  if (is.call(expr)) {
    fn <- expr[[1]]
    if (is.name(fn)) {
      fn_name <- as.character(fn)
      if (fn_name %in% known_names) {
        found <- c(found, fn_name)
      }
    }
    for (i in seq_along(expr)) {
      found <- c(found, find_calls(expr[[i]], known_names))
    }
  } else if (is.name(expr)) {
    nm <- as.character(expr)
    if (nm %in% known_names) {
      found <- c(found, nm)
    }
  }
  unique(found)
}
