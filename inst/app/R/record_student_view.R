#' Record a student view for teachers' pay
#'
#' This function logs a student's view of a PDF and updates
#'  total teacher's views
#' @param student_id The ID of the student viewing the PDF.
#' @param teacher_id The ID of the teacher associated with the PDF.
#' @param pdf_id The ID of the PDF being viewed.
#' @examples
#' \dontrun{
#'   record_student_view(
#'     student_id = "student123",
#'     teacher_id = "teacher456",
#'     pdf_id = "pdf789"
#'   )
#' }
#' @export
record_student_view <- \(
  student_id,
  teacher_id,
  pdf_id
){
  current_date <- format(Sys.time(), format = "%Y-%m-%d")
  # DB name
  db_name <- Sys.getenv("DATABASE_NAME")

  # Make SQLite connection
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  views_data <- dbReadTable(conn, "views")
  teachers_data <- dbReadTable(conn, "teachers")
  # check if view exists for today
  exists <- views_data |>
    filter(
      student_id == student_id &&
        teacher_id == teacher_id &&
        pdf_id == pdf_id &&
        date == current_date
    )

  if (nrow(exists) == 0) {
    new_data <- data.frame(
      student_id = student_id,
      teacher_id = teacher_id,
      pdf_id = pdf_id,
      date = current_date
    )

    DBI::dbAppendTable(conn = conn, name = "views", value = new_data)

    # update the teachers' total views
    teacher_data <- teachers_data |>
      filter(
        id == teacher_id
      )
    no_views <- as.numeric(teacher_data$views) + 1

    res <- dbSendQuery(
      conn,
      "UPDATE teachers
    SET views = :views
    WHERE id = :teacher_id"
    )

    dbBind(
      res,
      params = list(
        views = no_views,
        teacher_id = teacher_id
      )
    )
    dbClearResult(res)
  }
}
