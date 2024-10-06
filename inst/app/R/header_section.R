header_section <- tags$header(
  class = "fixed-top bg-default shadow",
  tags$div(
    class = "container d-flex align-items-center justify-content-between",
    tags$h1(
      class = "logo",
      tags$a(
        href = "",
        tags$img(
          id = "header_logo",
          src = file.path("logo", "logo_icon.png"),
          height = "50px"
        )
      )
    ),
    tags$nav(
      id = "navbar",
      class = "navbar",
      tags$ul(
        tags$li(
          class = "fade-in",
          shiny::actionLink(
            inputId = "home_link",
            label = "Home"
          )
        ),
        tags$li(
          class = "fade-in",
          actionLink(
            inputId = "about_us_link",
            label = "About Us"
          )
        ),
        tags$li(
          class = "fade-in",
          actionLink(
            inputId = "contact_us_link",
            label = "Contact Us"
          )
        ),
        tags$li(
          class = "fade-in",
          actionLink(
            inputId = "teachers_link",
            label = "Teachers"
          )
        ),
        tags$li(
          class = "fade-in",
          shiny::actionLink(
            inputId = "students_link",
            label = "Students"
          )
        ),
        tags$li(
          class = "fade-in",
          shiny::actionLink(
            inputId = "login_link",
            label = "Log In"
          )
        ),
        tags$li(
          class = "fade-in text-truncate w-75",
          shiny::actionLink(
            inputId = "signed_user_link",
            label = textOutput("signed_user")
          )
        )
      ),
      tags$i(
        class = "bi bi-list mobile-nav-toggle text-white"
      )
    )
  ),
  tags$head(
    tags$style(HTML("
      /* For smaller screens*/
      @media (max-width: 768px) {
        #header_logo {
          content: url('logo/logo_icon.png');
          width: 50px;
          height: auto;
          margin-left: 20px;
        }
      }
    "))
  )
)
