#' Launch the Shiny Application
#'
#' This function launches the Shiny application located in the `inst/app` directory.
#' @import shiny
#' @export
run_app <- function() {
  app_dir <- system.file("app", package = "coursework")
  if (app_dir == "") {
    stop("Could not find example directory. Try re-installing `coursework`.", call. = FALSE)
  }
  shiny::runApp(app_dir, display.mode = "normal")
}
