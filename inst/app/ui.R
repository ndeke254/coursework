ui <- shiny::bootstrapPage(
  tags$head(
    # browser favicon:
    tags$link(
      rel = "shortcut icon",
      href = file.path("logo", "logo_icon.png")
    ),

    # General stylesheet:
    tags$link(
      rel = "stylesheet",
      href = file.path("css", "styles.css")
    ),

    # bootstrap icons:
    tags$link(
      rel = "stylesheet",
      href = "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"
    ),

    # AOS js:
    tags$link(
      href = "https://unpkg.com/aos@2.3.1/dist/aos.css",
      rel = "stylesheet"
    ),
    tags$script(HTML("
    $(window).scroll(function() {
      if ($(window).scrollTop() +
       $(window).height() >= $(document).height() - 50) {
        Shiny.setInputValue('scrollToBottom', new Date().getTime());
      }
    });
  "))
  ),

  # Load dependencies
  useSweetAlert(),
  shinyjs::useShinyjs(),
  shinybusy::add_busy_spinner(
    spin = "fading-circle",
    position = "top-right",
    color = "#414042",
    margins = c("30%", "50%")
  ),
  tags$a(
    href = "#",
    class = "back-to-top d-flex align-items-center
             justify-content-center",
    tags$i(class = "bi bi-arrow-up")
  ),
  shiny::tabsetPanel(
    id = "panels",
    type = "hidden",
    selected = "landing_page",
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
      ),
      tabPanelBody(
        value = "admin_reg",
        div(
          class = "container text-center col-2",
          p("Your are an Administrator", class = "fw-semibold mt-5"),
          tags$img(
            src = "logo/logo.png",
            width = "100px"
          ),
          textInput(
            inputId = "admin_name",
            label = "Name:",
            placeholder = "Enter your name"
          ),
          actionButton(
            inputId = "admin_name_set",
            label = "SUBMIT"
          )
        )
      ),
      # dashboardpage----
      tabPanelBody(
        value = "dashboardpage_panel",
        tags$div(
          class = "fade-in",
          dashboard_page(),
        )
      )
    ),
    shinyjs::hidden(
      div(
        id = "company_copyright",
        class = "mt-5",
        p(
          HTML(
            '
                Copyright &copy;<span id = "year"></span>
                KEYTABU LTD.
                '
          ),
          style = "text-align: center;"
        ),
        p(
          "All Rights Reserved.",
          style = "text-align: center;"
        ),
        tags$script(
          'document.getElementById("year").innerHTML =
              new Date().getFullYear();'
        )
      )
    )
  ),
  tags$script(
    src = "https://unpkg.com/aos@2.3.1/dist/aos.js"
  ),
  tags$script(
    src = file.path("js", "landing-page.js")
  ),
  tags$script(
    src = file.path("js", "main.js")
  )
)
