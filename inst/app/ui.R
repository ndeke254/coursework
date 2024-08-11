# ----overall page ----
ui <- argonPage(
  title = "KEYTABU",
  # Load dependencies and error items
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
    tags$i(class = "ni ni-bold-up")
  ),
  tags$script(
    src = "https://unpkg.com/aos@2.3.1/dist/aos.js"
  ),
  tags$script(
    src = file.path("js", "landing-page.js")
  ),
  tags$script(
    src = file.path("js", "main.js")
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
  tagList(
    header_section,
    company_website,
    shinyjs::hidden(
      tags$div(
        id = "auth_page",
        argonSection(
          status = "secondary",
          mod_auth_ui("auth")
        )
      ),
      tags$div(
        id = "reg_student_page",
        argonR::argonSection(
          status = "secondary",
          student_registration_tab
        )
      ),
      tags$div(
        id = "reg_teacher_page",
        argonR::argonSection(
          status = "secondary",
          teacher_registration_tab
        )
      )
    ),
    shinyjs::hidden(
      tags$div(
        id = "admin_page",
        argonR::argonSection(
          status = "secondary",
          admin_registration_tab
        )
      )
    ),
    uiOutput("teacher_content"),
    student_content_tab
  )
)
