#' Update PDF Details in the Database
#'
#' @param pdf_id String. The unique identifier of the PDF entry to update.
#' @param grade String.The updated grade level for the PDF.
#' @param learning_area String. The updated learning area associated
#' with the PDF.
#' @param topic String. The updated topic for the PDF.
#' @param sub_topic String. The updated sub-topic for the PDF.
#' @examples
#' \dontrun{
#' # Example usage
#' update_pdf_details(
#'   pdf_id = PDF - 001,
#'   grade = 5,
#'   learning_area = "Mathematics",
#'   topic = "Addition",
#'   sub_topic = "Long Division"
#' )
#' }
#' @import DBI
#' @export
update_pdf_details <- \(
  pdf_id,
  grade,
  learning_area,
  topic,
  sub_topic
) {
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # Construct the SQL query to update the status
  res <-  DBI::dbSendQuery(
    conn,
    "UPDATE content
    SET grade = :grade,
    learning_area = :learning_area,
    topic = :topic,
    sub_topic = :sub_topic
    WHERE id = :pdf_id"
  )

   DBI::dbBind(
    res,
    params = list(
      grade = grade,
      learning_area = learning_area,
      topic = topic,
      sub_topic = sub_topic,
      pdf_id = pdf_id
    )
  )

   DBI::dbClearResult(res)
}
