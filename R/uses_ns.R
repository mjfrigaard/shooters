#' Check if expression contains Shiny module identifiers
#'
#' `uses_ns()` recursively walks a parsed R expression to detect calls
#' to [shiny::NS()] or [shiny::moduleServer()], which are reliable
#' indicators that a function is a Shiny module.
#'
#' @param expr A parsed R expression.
#'
#' @return Logical scalar; `TRUE` if a call to `NS()` or `moduleServer()`
#'   is found.
#'
#' @keywords internal
#'
uses_ns <- function(expr) {
  if (is.call(expr)) {
    fn <- expr[[1]]
    if (is.name(fn)) {
      fn_name <- as.character(fn)
      if (fn_name %in% c("NS", "moduleServer")) return(TRUE)
    }
    if (is.call(fn) && length(fn) == 3) {
      op <- as.character(fn[[1]])
      if (op %in% c("::", ":::")) {
        if (as.character(fn[[3]]) %in% c("NS", "moduleServer")) return(TRUE)
      }
    }
    for (i in seq_along(expr)) {
      if (uses_ns(expr[[i]])) return(TRUE)
    }
  }
  FALSE
}
