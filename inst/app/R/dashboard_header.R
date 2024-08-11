#' Dashboard Header
#'
#' @noRd
dashboard_header <- function() {
header <- bs4Dash::dashboardHeader(
  disable = FALSE,
  fixed = FALSE,
  status = "white",
  actionButton(
    inputId = "log_out",
    label = "Log out"
  ),
  title = bs4Dash::bs4DashBrand(
      tags$img(
        src = file.path("logo", "keytabu.svg"),
        style = "height: 45px;"
      )
  )
)
nav_tag_q <- header[[1]] |> htmltools::tagQuery()
nav_tag_q$addAttrs(style = "height: 63px;")
header[[1]] <- nav_tag_q$allTags()
return(header)
}
