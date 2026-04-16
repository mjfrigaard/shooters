test_that("returns FALSE for non-call expressions", {
  expect_false(uses_ns(quote(42)))
  expect_false(uses_ns(quote(x)))
  expect_false(uses_ns(as.name("NS")))   # bare name, not a call
})

test_that("returns FALSE for unrelated function calls", {
  expect_false(uses_ns(quote(paste("a", "b"))))
  expect_false(uses_ns(quote(renderPlot(plot(x)))))
})

test_that("detects NS() call directly", {
  expect_true(uses_ns(quote(NS(input$id))))
  expect_true(uses_ns(quote(ns <- NS(id))))
})

test_that("detects moduleServer() call directly", {
  expect_true(uses_ns(quote(moduleServer(id, function(input, output, session) {}))))
})

test_that("detects NS() nested inside a function body", {
  expr <- quote(function(id) {
    ns <- NS(id)
    tagList(textInput(ns("txt"), "Label"))
  })
  expect_true(uses_ns(expr))
})

test_that("detects shiny::NS() with namespace qualifier", {
  expect_true(uses_ns(quote(shiny::NS(id))))
})

test_that("detects shiny::moduleServer() with namespace qualifier", {
  expect_true(uses_ns(quote(shiny::moduleServer(id, function(input, output, session) {}))))
})

test_that("detects shiny:::NS() with triple-colon qualifier", {
  expect_true(uses_ns(quote(shiny:::NS(id))))
})

test_that("returns FALSE for deeply nested unrelated code", {
  expr <- quote(function(input, output) {
    output$plot <- renderPlot({
      plot(rnorm(100))
    })
  })
  expect_false(uses_ns(expr))
})
