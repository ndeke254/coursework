library(markdown)

# counties in Kenya
# used as a choices input in school registration tab
kenyan_counties <- c(
  "Baringo", "Bomet", "Bungoma", "Busia", "Elgeyo-Marakwet",
  "Embu", "Garissa", "Homa Bay", "Isiolo", "Kajiado",
  "Kakamega", "Kericho", "Kiambu", "Kilifi", "Kirinyaga",
  "Kisii", "Kisumu", "Kitui", "Kwale", "Laikipia",
  "Lamu", "Machakos", "Makueni", "Mandera", "Meru",
  "Migori", "Marsabit", "Mombasa", "Murang'a", "Nairobi",
  "Nakuru", "Nandi", "Narok", "Nyamira", "Nyandarua",
  "Nyeri", "Samburu", "Siaya", "Taita-Taveta", "Tana River",
  "Tharaka-Nithi", "Trans Nzoia", "Turkana", "Uasin Gishu",
  "Vihiga", "Wajir", "West Pokot"
)

# Learning areas
learning_areas <- c(
  "Indigenous Language",
  "Kiswahili",
  "Mathematics",
  "English",
  "Religious Education",
  "Environmental(Hygiene/Nutrition) activities",
  "Agriculture and Nutrition Activities",
  "Social studies",
  "Creative Arts",
  "Science and Technology",
  "Language Activities",
  "Creative Activities",
  "Environmental Activities",
  "Religious Activities",
  "Pastoral Programme of Instruction (PPI)",
  "Social Studies and Life Skills",
  "Agriculture and Home Science",
  "Integrated Science and Health Education",
  "Pre Technical Studies, Computer Studies and Business Studies",
  "Visual Arts, Performing Arts, Sports and PE"
)

# Retrieve credentials
app_name <- Sys.getenv("POLISHED_APP_NAME")
api_key <- Sys.getenv("POLISHED_API_KEY")
apiKey <- Sys.getenv("FIREBASE_API_KEY")
projectId <- Sys.getenv("projectId")
appId <- Sys.getenv("appId")
authDomain <- Sys.getenv("authDomain")
storageBucket <- Sys.getenv("storageBucket")
app_uid <- Sys.getenv("POLISHED_UID")
admin_email <- Sys.getenv("admin_email")

# configure polished auth
polished::polished_config(
  app_name = app_name,
  api_key = api_key,
  is_invite_required = FALSE
)

# configure firebase auth
# firebase::firebase_config(
# api_key = apiKey,
# project_id = projectId,
# app_id = appId
# )

# Set App api_key
polished::set_api_key(api_key = api_key)

label_mandatory <- \(label) {
  tagList(
    label,
    span("*", class = "text-danger")
  )
}

basic_primary_btn <- function(btn) {
  html_tag_q <- htmltools::tagQuery(btn)
  html_tag_q <- html_tag_q$removeClass("btn-default")
  html_tag_q <- html_tag_q$addClass("btn-primary")
  return(html_tag_q$allTags())
}

download_btn <- function(btn) {
  html_tag_q <- htmltools::tagQuery(btn)
  html_tag_q$removeClass("disabled")
  return(html_tag_q$allTags())
}

modified_switch <- function(switch) {
  html_tag_q <- htmltools::tagQuery(switch)
  html_tag_q$removeClass("shiny-input-container")
  return(html_tag_q$allTags())
}

Sys.setenv(GMAILR_KEY = Sys.getenv("GMAILR_KEY"))
