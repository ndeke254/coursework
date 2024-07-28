#' Dashboard Page
#' 
#' @noRd
dashboard_page <- function() {
  bs4Dash::bs4DashPage(
    header = dashboard_header(),
    sidebar = dashboard_sidebar(),
    body = dashboard_body(), 
    dark = NULL, 
    controlbar = NULL,
    title = "KEYTABU",
    scrollToTop = TRUE,
    help = NULL
  )
}
