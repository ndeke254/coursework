library(RSQLite)
library(DBI)
# make sqlite connection:
conn <- DBI::dbConnect(
  drv = RSQLite::SQLite(),
  "/home/jefferson.ndeke/PersonalR/coursework/inst/app/coursework.sqlite"
)

dbListTables(conn = conn)

table <- dbReadTable(conn, "teachers")
table


table$time[1]
table[5, "id"]
RSQLite::dbRemoveTable(conn, "content")
query <- "DELETE FROM students WHERE user_name LIKE '%Mwende%';"
query <- "DELETE FROM teachers WHERE school_name LIKE '%C%';"


query <- "UPDATE students
	SET paid = 1
  	WHERE grade = '5'
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
    status = character()
  ),
  row.names = integer(0),
  class = "data.frame"
)

DBI::dbWriteTable(
  conn = conn,
  name = "schools",
  value = school
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
    status = character(),
    views = integer()
  ),
  row.names = integer(0),
  class = "data.frame"
)
DBI::dbWriteTable(
  conn = conn,
  name = "teachers",
  value = teacher
)


# ----CONTENT ----
pdf <- structure(
  .Data = list(
    id = character(),
    school_name = character(),
    pdf_name = character(),
    teacher = character(),
    grade = character(),
    learning_area = character(),
    topic = character(),
    sub_topic = character(),
    time = character(),
    views = integer()
  ),
  row.names = integer(0),
  class = "data.frame"
)

DBI::dbWriteTable(
  conn = conn,
  name = "content",
  value = pdf
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
    status = character(),
    paid = integer()
  ),
  row.names = integer(0),
  class = "data.frame"
)
DBI::dbWriteTable(
  conn = conn,
  name = "students",
  value = student
)

# ---PAYMENTS ----
payments <- structure(
  .Data = list(
    user_email = character(),
    code = character(),
    amount = character(),
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
  value = payments
)





data <- data.frame(
  id = "SCH-001",
  name = "Kataa",
  level = "Primary",
  type = "Public",
  county = "Kitui",
  email = "kataa@gmail.com",
  status = "Enabled"
)
dbSendQuery(conn, "SELECT * FROM schools")

dbAppendTable(
  conn = con,
  name = "schools",
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
