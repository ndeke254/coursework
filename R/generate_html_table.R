# Helper function to generate HTML tables with custom CSS styling
#' @export
generate_html_table <- function(data, title) {
  if (nrow(data) > 0) {
    # Start the HTML table
    table_html <- paste0(
      '<div style="overflow-x:auto; padding: 10px; border-radius: 8px;">',
      '<h3 style="font-family: Montserrat, sans-serif; color: #003366;">', title, "</h3>",
      '<table style="width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden;">',
      '<thead style="background-color: #163142; color: #fff;">',
      "<tr>"
    )

    # Add table headers
    for (col in names(data)) {
      table_html <- paste0(
        table_html,
        '<th style="padding: 8px; text-align: left;">', col, "</th>"
      )
    }
    table_html <- paste0(table_html, "</tr></thead><tbody>")

    # Add table rows
    for (i in 1:nrow(data)) {
      table_html <- paste0(table_html, '<tr style="background-color: #f9f9f9;">')
      for (col in names(data)) {
        table_html <- paste0(
          table_html,
          '<td style="padding: 8px; text-align: left; border: 1px solid #50BD8C;">',
          data[i, col], "</td>"
        )
      }
      table_html <- paste0(table_html, "</tr>")
    }
    # Close the table
    table_html <- paste0(table_html, "</tbody></table></div>")

    return(table_html)
  } else {
    return(paste0("<h3>", title, "</h3><p>No data available.</p>"))
  }
}