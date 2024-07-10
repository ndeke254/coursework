#' Show an alert for cancelled action
#'
#' @param info String. A sentense to show the action done
#' @param position String. Where to place the alert on the window
#' @examples
#'
#' alert_warn_ui("Action cancelled!", "top-end", session)
#' @export
#'

alert_warn_ui <- \(info, position = "top-end", session) {
  show_toast(
    session = session,
    title = NULL,
    text = info,
    position = position,
    type = "warning",
    width = "auto",
    timer = 3000
  )
}
