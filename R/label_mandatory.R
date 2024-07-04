#' add a red star after an input label
#' @param label A string
#' @return A label with a red asterick
#'  @examples
#' shiny::actionButton(inputId = "confirm_btn", label = label_mandatory("Confirm"), icon = icon("check"))
#' 
#' @export 
#' 

label_mandatory <- function(label) {
  tagList(
    label,
    span("*", class = "text-danger")
  )
}