#' Dashboard Body
#'
#' @noRd
dashboard_body <- function() {
  bs4Dash::bs4DashBody(
    "here we go",
    div(
            textOutput(outputId = "signed_user", inline = TRUE)
  )
  )
}
