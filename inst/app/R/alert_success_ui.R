#' Show an alert for successful action
#'
#' @param info String. A sentense to show the action done
#' @param position String. Where to place the alert on the window

#' @examples
#'
#' success_alert_ui("User deleted successfully!", "top-end", session)
#' @export
#'
alert_success_ui <- \(info, position = "top-end", session, timer = 3000) {
  show_toast(
    session = session,
    title = NULL,
    text = info,
    position = position,
    type = "success",
    width = "auto",
    timer = timer
  )
}
