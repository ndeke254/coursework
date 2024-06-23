library(coursework)
library(shiny)
library(pdftools)
library(bslib)
library(magick)
library(shinyjs)
library(argonDash)
library(argonR)
library(bs4Dash)
library(shinyjs)
library(shinyWidgets)

# counties in Keya
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