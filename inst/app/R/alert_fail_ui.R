#' Show an alert for failed action
#'
#' @param info String. A sentense to show the action done
#' #' @param position String. Where to place the alert on the window

#' @examples
#'
#' fail_alert_ui("User delete failed!", "top-end", session)
#' @export
#'

alert_fail_ui <- \(info, position, session) {
  show_toast(
    session = session,
    title = NULL,
    text = info,
    position = "top-end",
    type = "error",
    width = "auto",
    timer = 3000
  )
}
