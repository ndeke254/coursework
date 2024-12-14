#' Create an aggregate of all payments in a school
#'
#' @param school_id String. School ID
#' @return data.frame.
#' @export
create_school_payments <- \(school_id) {
  # Make SQLite connection:
  db_name <- Sys.getenv("DATABASE_NAME")
  conn <- DBI::dbConnect(drv = RSQLite::SQLite(), db_name)
  on.exit(DBI::dbDisconnect(conn), add = TRUE)

  # read tables:
  schools_data <- DBI::dbReadTable(conn, "schools")
  pdf_data <- DBI::dbReadTable(conn, "content")
  teachers_data <- DBI::dbReadTable(conn, "teachers")
  students_data <- DBI::dbReadTable(conn, "students")

  # collect details:
  share_per_cent <- 1000 / 1500
  school_data <- schools_data |>
    dplyr::filter(id == school_id)
  termly_fees <- as.numeric(school_data$price)
  name <- school_data$school_name

  teachers_data <- teachers_data |>
    dplyr::filter(school_name == name) |>
    tidyr::separate_rows(grade, sep = ", ") |>
    dplyr::select(id, user_name, grade)

  pdf_data <- pdf_data |>
    dplyr::filter(teacher %in% teachers_data$user_name)

  student_data <- students_data |>
    dplyr::filter(school_name == name)

  # Calculate total PDFs and views per grade:
  grade_totals <- pdf_data |>
    dplyr::group_by(grade) |>
    dplyr::summarise(
      grade_total_pdfs = dplyr::n(),
      grade_total_views = sum(views),
      .groups = "drop"
    )

  # PDF counts per teacher and grade with views:
  pdf_counts <- pdf_data |>
    dplyr::group_by(teacher, grade) |>
    dplyr::summarise(
      teacher_pdf_count = dplyr::n(),
      teacher_total_views = sum(views),
      .groups = "drop"
    )

  # Paid students per grade:
  students_paid <- student_data |>
    dplyr::group_by(grade) |>
    dplyr::summarise(
      paid_students = sum(paid),
      .groups = "drop"
    )

  teachers_data$grade <- as.double(teachers_data$grade)
  grade_totals$grade <- as.double(grade_totals$grade)
  students_paid$grade <- as.double(students_paid$grade)
  pdf_counts$grade <- as.double(pdf_counts$grade)

  # add required columns:
  teacher_data_with_content <- teachers_data |>
    dplyr::left_join(
      pdf_counts,
      by = c("user_name" = "teacher", "grade" = "grade")
    ) |>
    dplyr::left_join(grade_totals, by = "grade") |>
    dplyr::left_join(students_paid, by = "grade") |>
    dplyr::mutate(
      content_score = teacher_pdf_count / grade_total_pdfs,
      expected_views = content_score * grade_total_views,
      engagement_multiplier = teacher_total_views / expected_views,
      per_share = content_score * engagement_multiplier,
      earnings = per_share * (share_per_cent * paid_students * termly_fees)
    ) |>
    tidyr::replace_na(
      list(
        content_score = 0,
        expected_views = 0,
        paid_students = 0
      )
    )
}
