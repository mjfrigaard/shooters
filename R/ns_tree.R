#' Display a plain-text namespace tree for a Shiny app
#'
#' `ns_tree()` statically parses all R source files in a directory,
#' builds a call graph of every function defined there, and prints a
#' plain-text tree showing how functions call one another. Functions that
#' use [shiny::NS()] or [shiny::moduleServer()] are identified as Shiny
#' modules, but their presence is not required — `ns_tree()` works for
#' any collection of R source files.
#'
#' The tree root is resolved with a three-tier fallback:
#' 1. `app_fun` — a named launcher function (e.g. `launch()`).
#' 2. `ui_fun` + `server_fun` — displayed as co-roots under `(app)` when no
#'    launcher is found (e.g. bare `ui` / `server` objects).
#' 3. All defined functions listed flat under `(app)` when neither of the
#'    above is found.
#'
#' @param path Character scalar; path to the directory containing R source
#'   files. Defaults to `"R"`.
#' @param app_fun Character scalar; name of the top-level app launch function
#'   used as the tree root. Defaults to `"launch"`.
#' @param ui_fun Character scalar; name of the UI function.
#'   Defaults to `"app_ui"`.
#' @param server_fun Character scalar; name of the server function.
#'   Defaults to `"app_server"`.
#'
#' @return Invisibly returns the nested tree structure (a list). The tree
#'   is printed to the console as a side effect.
#'
#' @examples
#' # Locate the bundled demo apps
#' apps <- system.file("apps", package = "shooters")
#'
#' # Bare ui/server — no wrapper functions, no modules
#' ns_tree(file.path(apps, "minimal"), ui_fun = "ui", server_fun = "server")
#'
#' # Helper functions, no Shiny modules
#' ns_tree(file.path(apps, "no_modules"))
#'
#' # One NS / moduleServer pair
#' ns_tree(file.path(apps, "single_module"))
#'
#' # Modules calling other modules (multi-file)
#' ns_tree(file.path(apps, "nested_modules"))
#'
#' @export
ns_tree <- function(path = "R",
                    app_fun = "launch",
                    ui_fun = "app_ui",
                    server_fun = "app_server") {

  r_files <- list.files(path, pattern = "\\.[Rr]$", full.names = TRUE)

  func_defs <- list()
  for (f in r_files) {
    exprs <- tryCatch(parse(f), error = function(e) NULL)
    if (is.null(exprs)) next
    for (expr in exprs) {
      def <- extract_func_def(expr)
      if (!is.null(def)) {
        func_defs[[def$name]] <- def$body
      }
    }
  }

  known_names <- names(func_defs)

  call_graph <- lapply(func_defs, function(body) {
    find_calls(body, known_names)
  })

  # --- three-tier root resolution -------------------------------------------

  if (app_fun %in% known_names) {
    # Tier 1: named launcher function exists
    tree <- build_tree(app_fun, call_graph, visited = character(0))

  } else {
    # Tier 2 / 3: synthesise a virtual "(app)" root
    ui_present     <- ui_fun     %in% known_names
    server_present <- server_fun %in% known_names

    if (ui_present || server_present) {
      # Tier 2: at least one of ui_fun / server_fun is defined
      co_roots <- intersect(c(ui_fun, server_fun), known_names)
    } else {
      # Tier 3: fall back to every defined function
      co_roots <- known_names
    }

    children <- lapply(co_roots, function(nm) {
      build_tree(nm, call_graph, visited = character(0))
    })
    names(children) <- co_roots
    tree <- list(name = "(app)", children = children)
  }

  # --------------------------------------------------------------------------

  lines <- render_tree(tree, prefix = "", is_last = TRUE, is_root = TRUE)
  cat(paste(lines, collapse = "\n"), "\n")

  invisible(tree)
}
