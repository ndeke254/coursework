# ----overall page ----
ui <- bslib::page(
  title = "KEYTABU",
  theme = bs_theme(version = 5),
  # Load dependencies
  useSweetAlert(),
  shinyjs::useShinyjs(),
  includeCSS("www/css/styles.css"),
  includeScript("www/js/script.js"),
  tags$head(
    # Browser favicon:
    tags$link(
      rel = "shortcut icon",
      href = file.path("logo", "logo_icon.png")
    ),

    # General stylesheet:
    tags$link(
      rel = "stylesheet",
      href = file.path("css", "styles.css")
    ),

    # Bootstrap icons:
    tags$link(
      rel = "stylesheet",
      href = "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.3/font/bootstrap-icons.css"
    ),

    # AOS js:
    tags$link(
      href = "https://unpkg.com/aos@2.3.1/dist/aos.css",
      rel = "stylesheet"
    )
  ),
  tags$a(
    href = "#",
    class = "back-to-top d-flex align-items-center justify-content-center",
    bsicons::bs_icon("arrow-up")
  ),
  tags$script(
    src = "https://unpkg.com/aos@2.3.1/dist/aos.js"
  ),
  tags$script(
    src = file.path("js", "landing-page.js")
  ),
  tags$script(
    src = file.path("js", "script.js")
  ),
  shinybusy::add_busy_spinner(
    spin = "fading-circle",
    position = "top-right",
    color = "#414042",
    margins = c("30%", "50%")
  ),
  header_section,
  tabsetPanel(
    id = "app_pages",
    type = "hidden",
    selected = "company_website",
    tabPanelBody(
      value = "company_website",
      company_website
    ),
    tabPanelBody(
      value = "auth_page",
      mod_auth_ui("auth")
    ),
    tabPanelBody(
      value = "reg_student_page",
      student_registration_tab
    ),
    tabPanelBody(
      value = "reg_teacher_page",
      teacher_registration_tab
    ),
    tabPanelBody(
      value = "admin_page",
      admin_registration_tab
    ),
    tabPanelBody(
      value = "teacher_content",
      teacher_request_tab
    ),
    tabPanelBody(
      value = "student_content",
      student_content_tab
    )
  )
)
