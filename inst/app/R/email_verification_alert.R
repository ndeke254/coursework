#' show a shiny alert for email verification
#'
#' @param email_address A character string. The user's email address.
#'
#' @return [shinyalert::shinyalert()]
#'
#' @examples
#' library(shiny)
#' shinyApp(
#'   ui = bslib::page(
#'     theme = bslib::bs_theme(version = 5),
#'     actionButton("show_modal", "Show Email Verification Modal")
#'   ),
#'   server = function(input, output, session) {
#'     observeEvent(input$show_alert, {
#'       email_address <- "user@example.com"
#'       modal <- email_verification_alert(email_address)
#'     })
#'   }
#' )
email_verification_alert <- \(email_address, session) {
  modal <- shinyalert(
    title = "Email verification required",
    text = paste0(
      "Click the link we just sent to ",
      tags$a(
        href = paste0("mailto:", email_address),
        email_address
      ),
      " to verify your email address, then log in."
    ),
    type = "",
    inputId = "verification_alert",
    imageUrl = "logo/logo_icon_blue.png",
    imageWidth = 100,
    imageHeight = 50,
    session = session,
    html = TRUE,
    confirmButtonText = "OK",
    confirmButtonCol = "#163142"
  )
}
