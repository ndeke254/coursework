library(RSQLite)
library(DBI)
# make sqlite connection:
conn <- DBI::dbConnect(
  drv = RSQLite::SQLite(),
  "inst/app/coursework.sqlite"
)

dbListTables(conn = conn)

table <- dbReadTable(conn, "timeline")


table

table$time[1]
table[5, "id"]
RSQLite::dbRemoveTable(conn, "content")
query <- "DELETE FROM administrator WHERE input LIKE '%musumbijefferson@gmail.com%';"
query <- "DELETE FROM teachers WHERE school_name LIKE '%C%';"


query <- "UPDATE teachers
  	SET views = 0
	 WHERE views = 1
  "
query <- "ALTER TABLE students
DROP COLUMN type"

query <- "ALTER TABLE teachers
  DELETE Y2024;"

query <- "ALTER TABLE users
ADD COLUMN paid INTEGER DEFAULT 0;"


dbExecute(conn, query)
# ---- SCHOOLS ----
school <- structure(
  .Data = list(
    id = character(),
    school_name = character(),
    level = character(),
    type = character(),
    county = character(),
    email = character(),
    price = character(),
    time = character(),
    status = character()
  ),
  row.names = integer(0),
  class = "data.frame"
)

DBI::dbWriteTable(
  conn = conn,
  name = "schools",
  value = school,
  overwrite = TRUE
)

# --- TEACHERS ----
teacher <- structure(
  .Data = list(
    id = character(),
    user_name = character(),
    school_name = character(),
    grade = character(),
    phone = character(),
    email = character(),
    time = character(),
    status = character(),
    views = integer()
  ),
  row.names = integer(0),
  class = "data.frame"
)
DBI::dbWriteTable(
  conn = conn,
  name = "teachers",
  value = teacher,
  overwrite = TRUE
)


# ----CONTENT ----
pdf <- structure(
  .Data = list(
    id = character(),
    pdf_name = character(),
    teacher = character(),
    grade = character(),
    learning_area = character(),
    topic = character(),
    sub_topic = character(),
    time = character(),
    status = character(),
    views = integer()
  ),
  row.names = integer(0),
  class = "data.frame"
)

DBI::dbWriteTable(
  conn = conn,
  name = "content",
  value = pdf,
  overwrite = TRUE
)

# --- STUDENTS -----
student <- structure(
  .Data = list(
    id = character(),
    user_name = character(),
    school_name = character(),
    grade = character(),
    phone = character(),
    email = character(),
    time = character(),
    status = character(),
    paid = integer()
  ),
  row.names = integer(0),
  class = "data.frame"
)

DBI::dbWriteTable(
  conn = conn,
  name = "students",
  value = student,
  overwrite = TRUE
)

# ---PAYMENTS ----
payments <- structure(
  .Data = list(
    ticket_id = character(),
    user_id = character(),
    code = character(),
    amount = character(),
    balance = character(),
    total = character(),
    number = character(),
    time = character(),
    term = character(),
    status = character()
  ),
  row.names = integer(0),
  class = "data.frame"
)

DBI::dbWriteTable(
  conn = conn,
  name = "payments",
  value = payments,
  overwrite = TRUE
)

# Requests

request <- structure(
  .Data = list(
    id = character(),
    teacher_id = character(),
    photos = character(),
    grade = character(),
    learning_area = character(),
    topic = character(),
    sub_topic = character(),
    time = character(),
    status = character()
  ),
  row.names = integer(0),
  class = "data.frame"
)

DBI::dbWriteTable(
  conn = conn,
  name = "requests",
  value = request,
  overwrite = TRUE
)


# Timeline

action <- structure(
  .Data = list(
    user = character(),
    action = character(),
    description = character(),
    time = character()
  ),
  row.names = integer(0),
  class = "data.frame"
)

DBI::dbWriteTable(
  conn = conn,
  name = "timeline",
  value = action,
  overwrite = TRUE
)

# views
views <- structure(
  .Data = list(
    student_id = character(),
    teacher_id = character(),
    pdf_id = character(),
    date = character()
  ),
  row.names = integer(0),
  class = "data.frame"
)

DBI::dbWriteTable(
  conn = conn,
  name = "views",
  value = views,
  overwrite = TRUE
)

# admin table
admin <- structure(
  .Data = list(
    input_col = c("term_end_date", "term_label"),
    value = c(NA, NA)
  ),
  row.names = 1:2,
  class = "data.frame"
)

DBI::dbWriteTable(
  conn = conn,
  name = "administrator",
  value = admin,
  overwrite = TRUE
)





data <- data.frame(
  id = "STU-001",
  user_name = "Jefferson Ndeke",
  school_name = "Kataa",
  grade = "5",
  phone = "706924458",
  email = "dieprazeptor@gmail.com",
  time = "2024-05-23 12:34:24",
  status = "Enabled",
  paid = 0
)
dbSendQuery(conn, "SELECT * FROM schools")

dbAppendTable(
  conn = conn,
  name = "students",
  value = data
)
register_new_school(
  conn = conn,
  table_name = "schools",
  data = pdf
)


# create the pdf template:

dbExecute(conn, "
  CREATE TABLE IF NOT EXISTS content (
    id TEXT,
    school_name TEXT,
    pdf_name TEXT,
    teacher TEXT,
    grade TEXT,
    learning_area TEXT,
    topic TEXT,
    sub_topic TEXT,
    time TIMESTAMP
  )
")


dbRemoveTable(conn, "schools")

existing_emails$content$email


get_new_user <- polished::get_users(
  email = "musumbijefferson@gmail.com"
)
email <- get_new_user$content$email
uid <- get_new_user$content$uid
user_role <- polished::get_user_roles(
  user_uid = uid
)
user_role$content$role_name
polished::get_app_users(email = "musumbijefferson@gmail.com")


rsconnect::deployApp()
rsconnect::accountInfo()
rsconnect::applications()
rsconnect::deployments()

remotes::install_github("https://github.com/ndeke254/coursework/")
pak::pkg_install("ndeke254/coursework")
install.packages("pak")
gitcreds::gitcreds_set()
remotes::install_github("ndeke254/coursework")
pak::pkg_install("ndeke254/coursework")
packageStatus()

update_request_status(request_id = "REQ-001", new_status = "PROCESSING")
file.remove(c("inst/app/www/requests/REQ-008-2.jpg", "inst/app/www/requests/REQ-008-3.jpg"))
getwd()



  record_admin_action(
    conn = conn,
    user = "Admin123",
    action = "Approve",
    description = "Approved ticket #038F389E"
  )

  library(data.table)

timeline_data <- read.csv("/home/jefferson.ndeke/PersonalR/coursework/inst/app/timeline.csv") |>
as.data.table()

currentPage = 3
pageSize = 10
offset <- (currentPage - 1) * pageSize

 data <- timeline_data[order(-time)][(offset + 1):(offset + pageSize), ]

timeline_data

signed_admin_user <- table |>
  filter(input == "musumbijefferson@gmail.com")
library(dplyr)
signed_admin_user <- table %>%
  dplyr::filter(input == user_details$email)

record_student_view(
  student_id = "STU-001",
  teacher_id = "TEA-001",
  pdf_id = "PDF-001"
)

library(dplyr)
admin_emails <- table |>
select(input) |>
  filter(grepl("@gmail\\.com$", input)) |>
  unlist() |>
  as.vector()

table
names(table) <- c("input_col", "value")



# Students table
students_data <- data.frame(
  id = sprintf("STD-%03d", 1:36),
  school_name = "Alpha",
  grade = c(rep(7, 31), sample(6:8, 5, replace = TRUE)), 
  paid = c(rep(1, 31), sample(0:1, 5, replace = TRUE)),
  time = Sys.time(),
  status = "Active"
)

# Define the content details for each teacher
content_details <- data.frame(
  teacher = teachers_data$user_name[-5],
  content_count = c(21, 43, 4, 23),
  total_views = c(142, 34, 45, 40)
)

# Generate the content table
# Define the content details for each teacher
content_details <- data.frame(
  teacher = teachers_data$user_name[-5],
  content_count = c(10, 17, 4, 27),
  total_views = c(54, 5, 35, 40)
)

# Generate the content table
pdf_data <- content_details |>
  dplyr::rowwise() |>
  dplyr::mutate(
    content_data = list(data.frame(
      id = sprintf("CONT-%03d", seq_len(content_count)),
      pdf_name = paste0("content_", seq_len(content_count)),
      teacher = teacher,
      grade = 7,
      learning_area = paste("Area", seq_len(content_count)),
      topic = paste("Topic", seq_len(content_count)),
      sub_topic = paste("Sub-topic", seq_len(content_count)),
      time = Sys.time(),
      status = "Active",
      views = rep(total_views / content_count, content_count)
    ))
  ) |>
  dplyr::select(content_data) |>
  tidyr::unnest(content_data)

dbWriteTable(conn, "content", pdf_data, append = TRUE)
paid <- DBI::dbReadTable(conn, "students")
paid |> dplyr::filter(
  paid == 1 & grade == 6
)
