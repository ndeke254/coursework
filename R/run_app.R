# R/run_app.R
#' Launch the Shiny Application
#'
#' @export
run_app <- function() {
  app_dir <- system.file("app", package = "coursework")
  shiny::runApp(app_dir)
}
