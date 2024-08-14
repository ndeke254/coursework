library(shiny)
library(htmltools)
library(shinyjs)
library(argonDash)
library(argonR)
library(bs4Dash)
library(shinyjs)
library(shinyWidgets)
library(RSQLite)
library(shinyvalidate)
library(plyr)
library(magick)
library(dplyr)
library(reactable)
library(prodlim)
library(bslib)
library(polished)
library(lubridate)
library(shinyalert)
library(polished)
library(frbs)
library(stringr)
library(magrittr)



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

# Learning areas in various school levels
lower_primary <- c(
  "Indigenous Language",
  "Kiswahili",
  "Mathematics",
  "English",
  "Religious Education",
  "Environmental(Hygiene/Nutrition) activities",
  "Creative activities"
)
upper_primary <- c(
  "English",
  "Mathematics",
  "Kiswahili",
  "Religious Education",
  "Agriculture and Nutrition Activities",
  "Social studies",
  "Creative Arts",
  "Science and Technology"
)
pre_primary <- c(
  "Language Activities",
  "Mathematics Activities",
  "Creative Activities",
  "Environmental Activities",
  "Religious Activities",
  "Pastoral Programme of Instruction (PPI)"
)
junior_secondary <- c(
  "Social Studies and Life Skills",
  "Agriculture and Home Science",
  "Integrated Science and Health Education",
  "Pre Technical Studies, Computer Studies and Business Studies",
  "Visual Arts, Performing Arts, Sports and PE",
  "Mathematics",
  "English",
  "Kiswahili",
  "Religious Education"
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

# configure polished auth
polished_config(
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
set_api_key(api_key = api_key)

label_mandatory <- \(label) {
  tagList(
    label,
    span("*", class = "text-danger")
  )
}

basic_primary_btn <- function(btn) {
  html_tag_q <- htmltools::tagQuery(btn)
  html_tag_q$removeClass("btn-default")
  return(html_tag_q$allTags())
}



