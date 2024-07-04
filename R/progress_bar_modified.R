#' include 100% in the progessBar
#' origin function from ArgonR has excluded 0% and 100%
#' I want a full bar on last page
#' @param value String. Numeric string to show progress
#' @param text String. Show label on the progress
#' @param status String. A color string showing the class to apply
#'@example progress_bar_modified(text = page_text, value = progress_value, status = "gradient-gray")
#' @export

progress_bar_modified <- function(value, text = NULL, status = "primary") {
    stopifnot(value <= 100)
    progressWrapper <- htmltools::tags$div(class = "progress-wrapper")
    progressTag <- htmltools::tags$div(class = "progress-info justify-content-center")
    progressLabel <- if (!is.null(text)) {
        htmltools::tags$div(class = "progress-label rounded", htmltools::tags$span(text, class = "text-lighter"))
    }
    progressPercent <- htmltools::tags$div(
        class = "progress-percentage d-none",
        htmltools::span(paste0(value, "%"))
    )
    progressBar <- htmltools::tags$div(class = "progress m-auto w-75", htmltools::tags$div(
        class = paste0(
            "progress-bar bg-",
            status
        ), role = "progressbar", `aria-valuenow` = value,
        `aria-valuemin` = "0", `aria-valuemax` = "100", style = paste0(
            "width: ",
            value, "%;"
        )
    ))
    progressTag <- htmltools::tagAppendChildren(
        progressTag,
        progressLabel, progressPercent
    )
    htmltools::tagAppendChildren(
        progressWrapper, progressTag,
        progressBar
    )
}
