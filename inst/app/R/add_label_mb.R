#' Add label's bottom margin
#'
#' Finds the `label` tag and adds the class 'mb-2' to it.
#' @param shinywidget_input The shinyWidget input to add margin to.
#' @return [htmltools::tag()]
#' @export
add_label_mb <- \(shinywidget_input) {
  tag_query <- htmltools::tagQuery(shinywidget_input)
  tag_query$find("label")$addClass("mb-2")
  tag_query$allTags()
}
