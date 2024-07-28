#' @noRd
mod_landing_page_server <- function(id, parent_session) {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      # on click, add class 'active' to the clicked nav link:
      add_class_active <- \(id) {
        shinyjs::removeClass(class = "active", selector = "header .nav-link")
        shinyjs::addClass(id = id, class = "active")
      }

      # change login page html depending on whether the action is sign in
      # or sign up:
      change_login_html <- \(action) {
        # text to show on '.firebaseui-title':
        txt <- switch(
          EXPR = action,
          signin = "Sign in with email",
          signup = "Create an account"
        )
        shinyjs::html(selector = ".firebaseui-title", html = txt)
      }

      # go_signin_*:
      lapply(
        X = c(paste0("go_signin_", 1:3)),
        FUN = \(x) {
          shinyjs::onclick(
            id = x,
            expr = {
              selector <- ".firebase-login"
              shinyjs::hide(selector = selector)
              # switch to login section:
              shiny::updateTabsetPanel(
                session = session,
                inputId = "hero_and_login",
                selected = "login_section"
              )
              # add class 'active' to nav link:
              if (x != "go_signin_3") {
                add_class_active(id = x)
              }
              if (x == "go_signin_3") {
                add_class_active(id = "go_signin_1")
              }
              # change inner HTML of '.firebaseui-title':
              if (x %in% paste0("go_signin_", c(1, 3))) {
                change_login_html(action = "signin")
              }
              if (x == "go_signin_2") {
                change_login_html(action = "signup")
              }
              shinyjs::delay(
                ms = 100,
                expr = shinyjs::show(
                  selector = selector,
                  anim = TRUE,
                  animType = "slide"
                )
              )
            }
          )
        }
      )

      # home:
      shinyjs::onclick(
        id = "home",
        expr = {
          add_class_active(id = "home")

          shiny::updateTabsetPanel(
            session = session,
            inputId = "hero_and_login",
            selected = "hero_section"
          )
        }
      )

      # sign in----
      f <- firebase::FirebaseUI$
        new()$
        set_providers(email = TRUE)$
        set_privacy_policy_url("#")$
        set_tos_url("#")$
        launch()

      observeEvent(f$get_signed_in(),
        {
          x <- f$get_signed_in()
          email <- x$response$email

          updateTabsetPanel(
            session = session,
            inputId = "login_and_selection",
            selected = "before_verification"
          )

          # if user is not verified, send verification email:
          cond <- isTruthy(x$response$emailVerified)
          if (!cond) {
            f$send_verification_email()
            modal <- email_verification_modal(email)
            shiny::showModal(modal)
            shiny::updateTabsetPanel(
              session = session,
              inputId = "login_and_selection",
              selected = "before_verification"
            )
            # jump out of this observeEvent:
            return(NULL)
          }

          # otherwise if user has already verified email:
          shinytoastr::toastr_success(
            message = htmltools::doRenderTags(
              x = tags$h6("Signed In!")
            ),
            position = "bottom-center",
            closeButton = TRUE,
            progressBar = TRUE
          )

          updateTabsetPanel(
            session = parent_session,
            inputId = "panels",
            selected = "dashboardpage_panel"
          )
        },
        ignoreNULL = TRUE
      )

      details <- reactive({
        f$req_sign_in()

        # who's signed in?
        x <- f$get_signed_in()

        # require email verification:
        req(x$response$emailVerified)

        list(f = f)
      })

      # return the reactive `details`:
      return(details)
    }
  )
}
