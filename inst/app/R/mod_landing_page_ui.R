#' @noRd
mod_landing_page_ui <- function(id) {
  ns <- NS(namespace = id)

  # NB: In this section, 'ns' may have been intentionally ommited
  # for some ids so that they are easily accessible via css & js
  header_section <- div(
    tags$div(
      class = "container d-flex align-items-center justify-content-between",
      tags$h1(
        class = "logo",
        tags$a(
          href = "",
          tags$img(
            src = file.path("logo", "logo_white.svg"),
            height = "180px"
          )
        )
      ),
      tags$nav(
        id = "navbar",
        class = "navbar",
        tags$ul(
          tags$li(
            shiny::actionLink(
              inputId = ns("home"),
              class = "nav-link scrollto active d-none",
              label = "Home"
            )
          ),
          tags$li(
            class = "fade-in",
            id = ns("signin_li"),
            tags$a(
              id = ns("go_signin_1"),
              class = "getstarted nav-link scrollto",
              href = "#",
              "Sign In"
            )
          ),
          tags$li(
            shiny::actionLink(
              inputId = ns("go_signin_2"),
              class = "scrollto nav-link",
              label = "Sign Up"
            )
          )
        ),
        tags$i(
          class = "bi bi-list mobile-nav-toggle"
        )
      )
    )
  )

  login_section <- tags$div(
    class = "hero d-flex align-items-start",
    tags$div(
      class = "container position-relative",
      `data-aos` = "fade-up",
      `data-aos-delay` = "100",
      shiny::tabsetPanel(
        id = ns("login_and_selection"),
        type = "hidden",
        selected = "login",
        tabPanelBody(
          value = "login",
          tags$div(
            class = "fade-in my-5 py-5",
            tags$div(
              class = "login-container",
              tags$div(
                class = "firebase-login",
                firebase::firebaseUIContainer()
              )
            )
          )
        ),
        shiny::tabPanelBody(
          value = "before_verification",
          shiny::uiOutput(outputId = ns("verify_ui"))
        )
      )
    )
  )

  shiny::tagList(
    header_section,
    tags$head(
      tags$style(
        HTML("background-color: #1D2856);")
      )
    ),
    shiny::tabsetPanel(
      id = ns("hero_and_login"),
      type = "hidden",
      selected = NULL,
      shiny::tabPanelBody(
        value = "login_section",
        login_section
      )
    )
  )
}
