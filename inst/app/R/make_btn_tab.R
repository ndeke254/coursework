
#' Remove class 'btn-default' from a button
#'
#' Useful since bs4Dash behaves differently
#'
#' @param btn shiny::actionButton
#' @examples
#' btn <- shiny::actionButton(
#' inputId = "theid",
#' label = "The Label",
#' class = "btn-outline-dark"
#' )
#' remove_btn_default(btn)
#'@export 
#' 
make_btn_tab <- \(btn) {
  html_tag_q <- htmltools::tagQuery(btn)
  html_tag_q$removeClass("btn-default")
  return(html_tag_q$allTags())
}
