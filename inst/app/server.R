server <- function(input, output, session) {
  if (in_development_mode()) {
    updateTabsetPanel(
      session = session,
      inputId = "panels",
      selected = "dashboardpage_panel"
    )
    session$onSessionEnded(\() {
      cat("\n")
      stopApp()
    })
  }

 # ----landing page----
  if (in_production_mode()) {
    rv_login_details <- mod_landing_page_server(
      id = "landing_page",
      parent_session = session
    )
    # firebase auth:
    r_f <- reactive(rv_login_details()$f)
  }

  if (in_development_mode()) {
    # create a fake r_f object:
    r_f <- reactive(TRUE)
  }

  # Hide main landing page
  observeEvent(input$log_link, {
    updateTabsetPanel(
      session = session,
      inputId = "panels",
      selected = "signin_page"
    )
 #   shinyjs::hide("main", anim = TRUE, animType = "fade")
  #  shinyjs::hide("intro_page", anim = TRUE, animType = "fade")
 #   shinyjs::hide("explanation_page", anim = TRUE, animType = "fade")
 #   shinyjs::hide("cards_page", anim = TRUE, animType = "fade")
 #   shinyjs::hide("about_page", anim = TRUE, animType = "fade")
 #   shinyjs::hide("partners_page", anim = TRUE, animType = "fade")
 #   shinyjs::hide("stats_page", anim = TRUE, animType = "fade")
  })
}
