#' Customize a tabsetPanel
#'
#' This function customizes a tabsetPanel by adding additional CSS classes to
#' the elements.
#'
#' @param tabsetpanel The tabsetPanel to customize.
#' @param container_class Classes to apply to the container
#' @param ul_class Classes to apply to the `ul`
#'
#' @return The customized tabsetPanel.
#'
#' @examples
#' # Assuming you have a tabsetPanel defined as 'myTabsetPanel'
#' customize_tabsetpanel(myTabsetPanel)
#'
customize_tabsetpanel <- function(
    tabsetpanel,
    container_class = "px-5",
    ul_class = "justify-content-between bg-white pt-2 rounded"
  ) {
  html_tag_q <- htmltools::tagQuery(tabsetpanel)
  html_tag_q$addClass(container_class)$
    find("ul")$addClass(ul_class)

  html_tag_q$allTags()
}
