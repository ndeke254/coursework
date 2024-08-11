#' Custom reactable renderer
#'
#' @param data A data.frame/data.table object.
#' The data to render in the table.
#' @param name_col String. The column to look for `colored_rows` in.
#' Defaults to "name".
#' @param colored_rows Character vector. The values of the `name_col`
#' for which the rows will be colored differently.
#' Defaults to `NULL`.
#' @return [reactable::renderReactable()]
render_reactable <- \(data, name_col = "name", colored_rows = NULL) {
  reactable::renderReactable({
    data <- data.table::as.data.table(data)

    columns <- list()
    nms <- names(data)
    numeric_columns <- nms[sapply(data, is.numeric)]
    integer_columns <- nms[sapply(data, is.integer)]
    numeric_col_defs <- lapply(numeric_columns, \(clmn) {
      digits <- if (clmn %in% integer_columns) 0 else 2
      reactable::colDef(
        format = reactable::colFormat(
          separators = TRUE,
          digits = digits
        ),
        minWidth = 150
      )
    })
    names(numeric_col_defs) <- numeric_columns
    columns <- c(columns, numeric_col_defs)

    row_style <- NULL
    row_class <- NULL

    if (!is.null(name_col) && !is.null(colored_rows)) {
      row_style <- \(index) {
        cond <- tolower(data[[name_col]][[index]]) %in% tolower(colored_rows)
        if (cond) {
          list(
            background = "var(--bg-color)",
            color = "var(--custom-blue)"
          )
        }
      }
      row_class <- \(index) {
        cond <- tolower(data[[name_col]][[index]]) %in% tolower(colored_rows)
        if (cond) "fw-bold"
      }
    }

    height <- if (nrow(data) >= 10) 600 else NULL

    reactable::reactable(
      data = data,
      wrap = FALSE,
      highlight = TRUE,
      bordered = TRUE,
      resizable = TRUE,
      columns = columns,
      pagination = FALSE,
      rowStyle = row_style,
      rowClass = row_class,
      height = height
    )
  })
}
