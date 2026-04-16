test_that("returns NULL for non-call expressions", {
  expect_null(extract_func_def(quote(42)))
  expect_null(extract_func_def(quote(x)))
  expect_null(extract_func_def(as.name("foo")))
})

test_that("returns NULL when RHS is not a function", {
  expect_null(extract_func_def(quote(x <- 1)))
  expect_null(extract_func_def(quote(x <- "hello")))
  expect_null(extract_func_def(quote(x <- list(1, 2))))
})

test_that("extracts name and body with <- assignment", {
  expr <- quote(my_fun <- function(x) x + 1)
  result <- extract_func_def(expr)
  expect_equal(result$name, "my_fun")
  expect_true(is.call(result$body))
  expect_equal(as.character(result$body[[1]]), "function")
})

test_that("extracts name and body with = assignment", {
  # quote(my_fun = ...) is parsed as a named arg, so use parse(text=) instead
  expr <- parse(text = "my_fun = function(x) x * 2")[[1]]
  result <- extract_func_def(expr)
  expect_equal(result$name, "my_fun")
  expect_true(is.call(result$body))
})

test_that("extracts name and body with assign()", {
  expr <- quote(assign("my_fun", function(x) x))
  result <- extract_func_def(expr)
  expect_equal(result$name, "my_fun")
  expect_true(is.call(result$body))
})

test_that("returns NULL when assign() name is not a string", {
  expr <- quote(assign(my_fun, function(x) x))
  expect_null(extract_func_def(expr))
})

test_that("returns NULL when LHS is not a simple name", {
  expr <- quote(x$foo <- function(x) x)
  expect_null(extract_func_def(expr))
})

test_that("works with multi-argument functions", {
  expr <- quote(f <- function(x, y, z = 1) x + y + z)
  result <- extract_func_def(expr)
  expect_equal(result$name, "f")
})
