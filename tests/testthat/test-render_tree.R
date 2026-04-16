# helpers ------------------------------------------------------------------

leaf <- function(name) list(name = name, children = list())

node <- function(name, ...) {
  kids <- list(...)
  names(kids) <- vapply(kids, `[[`, character(1), "name")
  list(name = name, children = kids)
}

# root rendering -----------------------------------------------------------

test_that("root node renders with block prefix", {
  tree <- leaf("root")
  lines <- render_tree(tree)
  expect_equal(lines[[1]], "\u2588\u2500root")
})

test_that("root-only tree produces exactly one line", {
  tree <- leaf("root")
  lines <- render_tree(tree)
  expect_length(lines, 1L)
})

# single child -------------------------------------------------------------

test_that("single child uses └─ connector", {
  tree <- node("root", leaf("child"))
  lines <- render_tree(tree)
  expect_match(lines[[2]], "^\u2514\u2500\u2588\u2500child$")
})

test_that("single child tree has two lines", {
  tree <- node("root", leaf("only"))
  lines <- render_tree(tree)
  expect_length(lines, 2L)
})

# multiple children --------------------------------------------------------

test_that("non-last siblings use ├─ connector", {
  tree <- node("root", leaf("a"), leaf("b"), leaf("c"))
  lines <- render_tree(tree)
  expect_match(lines[[2]], "^\u251c\u2500\u2588\u2500a$")
  expect_match(lines[[3]], "^\u251c\u2500\u2588\u2500b$")
  expect_match(lines[[4]], "^\u2514\u2500\u2588\u2500c$")
})

test_that("three-children tree has four lines total", {
  tree <- node("root", leaf("a"), leaf("b"), leaf("c"))
  lines <- render_tree(tree)
  expect_length(lines, 4L)
})

# nested children ----------------------------------------------------------

test_that("grandchildren are indented under └─ parent", {
  tree <- node("root",
    node("parent", leaf("child"))
  )
  lines <- render_tree(tree)
  # parent line
  expect_match(lines[[2]], "\u2514\u2500\u2588\u2500parent")
  # child line — indented with two spaces (last-child continuation)
  expect_match(lines[[3]], "^  \u2514\u2500\u2588\u2500child$")
})

test_that("grandchildren under non-last parent use │ continuation", {
  tree <- node("root",
    node("p1", leaf("child")),
    leaf("p2")
  )
  lines <- render_tree(tree)
  # p1 is NOT last, so its children should be prefixed with "│ "
  expect_match(lines[[3]], "^\u2502 \u2514\u2500\u2588\u2500child$")
})

# virtual (app) root -------------------------------------------------------

test_that("virtual (app) root renders correctly", {
  tree <- list(
    name = "(app)",
    children = list(
      ui     = leaf("ui"),
      server = leaf("server")
    )
  )
  lines <- render_tree(tree)
  expect_match(lines[[1]], "\u2588\u2500\\(app\\)")
  # both children present
  expect_match(lines[[2]], "\u251c\u2500\u2588\u2500ui")
  expect_match(lines[[3]], "\u2514\u2500\u2588\u2500server")
})
