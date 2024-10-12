#' Show an alert for failed action
#'
#' @param info String. A sentense to show the action done
#' #' @param position String. Where to place the alert on the window

#' @examples
#'
#' alert_fail_ui("User delete failed!", "top-end", session)
#' @export
alert_fail_ui <- \(info, position = "top-end", session, timer = 3000) {
  shinyWidgets::show_toast(
    session = session,
    title = NULL,
    text = info,
    position = position,
    type = "error",
    width = "auto",
    timer = timer
  )
}
