#' Create an Email Verification Modal Dialog
#'
#' Generate a modal dialog that prompts the user to verify their
#' email address.
#'
#' @param email_address A character string. The user's email address.
#'
#' @return [shiny::modalDialog()]
#'
#' @examples
#' library(shiny)
#' shinyApp(
#'     ui = bslib::page(
#'         theme = bslib::bs_theme(version = 5),
#'         actionButton("show_modal", "Show Email Verification Modal")
#'     ),
#'     server = function(input, output, session) {
#'         observeEvent(input$show_modal, {
#'             email_address <- "user@example.com"
#'             modal <- email_verification_modal(email_address)
#'             showModal(modal)
#'         })
#'     }
#' )
email_verification_modal <- \(email_address) {
    modal <- shiny::modalDialog(
        title = p("Email verification required",
            class = "text-bold"
        ),
        easyClose = FALSE,
        size = "m",
        footer = NULL,
        tags$h5(
            class = "card card-body border-0 modal-dialog-centered",
            tags$span(
                "Click the link we just sent to ",
                tags$a(
                    href = paste0("mailto:", email_address),
                    email_address
                ),
                " to verify your email address.
                 Once you're done, refresh this page & sign in."
            )
        )
    )
}
