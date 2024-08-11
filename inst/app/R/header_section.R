header_section <- div(
  class = "bg-default heading-title ",
  tags$div(
    class = "container d-flex align-items-center justify-content-between",
    div(
      class = "logo",
      tags$a(
        href = "",
        tags$img(
          src = file.path("logo", "logo_white.svg"),
          height = "140px"
        )
      )
    ),
    tags$nav(
      id = "navbar",
      class = "navbar",
      tags$ul(
        tags$li(
          class = "fade-in",
          actionLink(
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
      )
    )
  )
)
