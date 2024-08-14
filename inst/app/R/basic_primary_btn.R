
#' Remove class 'btn-default' from a button
#' Add the `btn-primary` class
#'
#' @param btn shiny::actionButton
#' @examples
#' btn <- shiny::actionButton(inputId = "theid", label = "The Label", class = "btn-outline-dark")
#' basic_primary_btn(btn)
#' @export
basic_primary_btn <- function(btn) {
  html_tag_q <- htmltools::tagQuery(btn)
  html_tag_q$removeClass("btn-default")
  return(html_tag_q$allTags())
}
