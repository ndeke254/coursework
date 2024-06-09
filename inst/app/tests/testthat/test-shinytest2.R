library(shinytest2)

test_that("{shinytest2} recording: app", {
  app <- AppDriver$new(variant = platform_variant(), name = "app", height = 929, 
      width = 1549)
  app$expect_values()
  app$expect_screenshot()
})
