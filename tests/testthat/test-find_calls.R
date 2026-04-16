test_that("returns empty vector when no known names are present", {
  expr <- quote(paste("hello", "world"))
  expect_equal(find_calls(expr, c("foo", "bar")), character(0))
})

test_that("returns empty vector for non-call, non-name expression", {
  expect_equal(find_calls(quote(42), c("foo")), character(0))
  expect_equal(find_calls(quote("string"), c("foo")), character(0))
})

test_that("finds a direct function call", {
  expr <- quote(foo(1, 2))
  expect_equal(find_calls(expr, c("foo", "bar")), "foo")
})

test_that("finds multiple distinct calls", {
  expr <- quote({
    foo(1)
    bar(2)
  })
  result <- find_calls(expr, c("foo", "bar", "baz"))
  expect_setequal(result, c("foo", "bar"))
})

test_that("deduplicates repeated calls", {
  expr <- quote({
    foo(1)
    foo(2)
    foo(3)
  })
  expect_equal(find_calls(expr, "foo"), "foo")
})

test_that("finds nested calls", {
  expr <- quote(foo(bar(1)))
  result <- find_calls(expr, c("foo", "bar"))
  expect_setequal(result, c("foo", "bar"))
})

test_that("does not match unknown names", {
  expr <- quote(unknown_fn(1))
  expect_equal(find_calls(expr, c("foo", "bar")), character(0))
})

test_that("finds bare name references", {
  # A known name used as a value (not called) should also be found
  expr <- quote(lapply(list(1, 2), foo))
  expect_equal(find_calls(expr, "foo"), "foo")
})

test_that("works on a realistic server function body", {
  expr <- quote(function(input, output, session) {
    data <- make_data()
    render_scatter(data)
  })
  result <- find_calls(expr, c("make_data", "render_scatter", "other_fn"))
  expect_setequal(result, c("make_data", "render_scatter"))
})
