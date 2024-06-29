library(coursework)
library(shiny)
library(pdftools)
library(magick)
library(shinyjs)
library(argonDash)
library(argonR)
library(bs4Dash)
library(shinyjs)
library(shinyWidgets)
library(RSQLite)
library(shinyvalidate)
library(dplyr)
library(reactable)
library(prodlim)
library(bslib)

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

