test_that("leaf node has correct name and empty children", {
  graph <- list(foo = character(0))
  result <- build_tree("foo", graph)
  expect_equal(result$name, "foo")
  expect_equal(result$children, list())
})

test_that("single child is nested correctly", {
  graph <- list(
    root = "child",
    child = character(0)
  )
  result <- build_tree("root", graph)
  expect_equal(result$name, "root")
  expect_equal(length(result$children), 1L)
  expect_equal(result$children[["child"]]$name, "child")
})

test_that("multiple children are all present", {
  graph <- list(
    root  = c("a", "b", "c"),
    a     = character(0),
    b     = character(0),
    c     = character(0)
  )
  result <- build_tree("root", graph)
  expect_setequal(names(result$children), c("a", "b", "c"))
})

test_that("nested children are built recursively", {
  graph <- list(
    root  = "parent",
    parent = "child",
    child  = character(0)
  )
  result <- build_tree("root", graph)
  parent_node <- result$children[["parent"]]
  expect_equal(parent_node$name, "parent")
  child_node  <- parent_node$children[["child"]]
  expect_equal(child_node$name, "child")
  expect_equal(child_node$children, list())
})

test_that("cycles are broken and do not infinite-loop", {
  graph <- list(
    a = "b",
    b = "a"   # cycle: a -> b -> a
  )
  result <- build_tree("a", graph)
  expect_equal(result$name, "a")
  # b is a child, but a should not re-appear under b
  b_node <- result$children[["b"]]
  expect_equal(b_node$name, "b")
  expect_equal(b_node$children, list())
})

test_that("self-referencing node does not infinite-loop", {
  graph <- list(f = "f")
  result <- build_tree("f", graph)
  expect_equal(result$name, "f")
  expect_equal(result$children, list())
})

test_that("node missing from call graph produces leaf", {
  graph <- list(root = "unknown")
  result <- build_tree("root", graph)
  # "unknown" is a child name but has no entry in the graph -> leaf
  expect_equal(result$children[["unknown"]]$name, "unknown")
  expect_equal(result$children[["unknown"]]$children, list())
})
