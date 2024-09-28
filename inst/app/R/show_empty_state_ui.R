#' Create a container to show when no data is found
#'
#'
show_empty_state_ui <- div(
  div(
    class = "d-flex justify-content-center mt-5",
    img(src = "logo/emptystate.svg", alt = "No Data Available!")
  ),
  div(
    class = "font-weight-900 text-center",
    "No Records Available"
  ),
  div(
    class = "text-sm-center text-muted",
    "You may need to check for filters"
  )
)
