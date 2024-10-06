#' Authentication module UI
#'
#' @param id Module id
mod_auth_ui <- \(id) {
    ns <- NS(id)
    reset_btn_id <- ns("reset_password_btn")

    tagList(
        tags$head(
            tags$style(HTML("
        /* Center the card on the page */
        .centered-container {
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          padding: 10px; /* Padding for small screens */

        }

       .split-card {
          display: flex;
          flex-direction: row;
          width: 100%;
          max-width: 800px;
          height: auto;
          border-radius: 5px;
          overflow: hidden;
          background-color: white;
        }

        /* Left side with image */
        .split-card-left {
          width: 50%;
          background: url('logo/girl_child.png') no-repeat center center;
          background-size: 100%;
        }

               /* Left side with image */
        .split-card-left-reset {
          width: 50%;
          background: url('logo/girl_forgot.png') no-repeat center center;
          background-size: 90%;
        }

        /* Right side with form */
        .split-card-right {
          width: 50%;
          background-color: white;
          display: flex;
          flex-direction: column;
          justify-content: center;
          padding: 5px;
        }

        /* Responsive layout */
        @media (max-width: 768px) {
          .split-card {
            flex-direction: column;
            height: auto;
          }

          .split-card-left,
          .split-card-right {
            width: 100%;
            height: auto;
          }

          .split-card-left {
            background-size: cover;
            background-position: center;
          }

          .split-card-right {
            padding: 30px;
          }
        }

        @media (max-width: 480px) {
          .split-card-right {
            padding: 5px;
          }"))
        ),

        # toggle password
        tags$script(HTML("
            function togglePassword(id) {
                var x = document.getElementById(id);
                if (x.type === 'password') {
                    x.type = 'text';
                } else {
                    x.type = 'password';
                }
            }
        ")),
        div(
            style = "
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('logo/login_background.jpg');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            opacity: 0.4;  /* Damped opacity */
            mask-image: linear-gradient(to right, black 70%, transparent 100%);
        "
        ),

        # Centered card layout
        div(
            class = "centered-container",
            div(
                class = "split-card card",

                # Left side with background image
                div(
                    id = ns("login_background_image"),
                    class = "split-card-left bg-default"
                ),
                shinyjs::hidden(
                    div(
                        id = ns("reset_background_image"),
                        class = "split-card-left-reset bg-default"
                    )
                ),

                # Right side with form
                div(
                    class = "split-card-right border",
                    tabsetPanel(
                        id = ns("auth_pages"),
                        type = "hidden",
                        selected = "login_page",
                        tabPanelBody(
                            value = "login_page",
                            div(
                                class = "container",
                                div(
                                    title_icon = NULL,
                                    tags$div(
                                        id = ns("auth_loader"),
                                        class = "auth_form_loader shinyjs-hide bg-default"
                                    ),
                                    div(
                                        class = "text-center pt-2",
                                        tags$img(
                                            src = file.path("logo", "logo_icon_blue.png"),
                                            width = "70px"
                                        ),
                                        h5("Log in Candidate",
                                            class = "text-body-1 text-bold
                                            pt-3"
                                        )
                                    ),
                                    login_form(ns = ns),
                                    tags$div(
                                        class = "text-center",
                                        tags$p(
                                            class = "mt-3 small text-bold",
                                            "Forgot password?",
                                            actionLink(
                                                inputId = ns("reset_password"),
                                                label = "Reset"
                                            )
                                        )
                                    )
                                )
                            )
                        ),
                        tabPanelBody(
                            value = "reset_page",
                            div(
                                class = "container",
                                div(
                                    title_icon = NULL,
                                    tags$div(
                                        id = ns("authr_loader"),
                                        class = "auth_form_loader shinyjs-hide bg-default"
                                    ),
                                    tags$div(
                                        class = "d-flex justify-content-center pt-2",
                                        tags$img(
                                            src = file.path("logo", "logo_icon_blue.png"),
                                            width = "70px"
                                        )
                                    ),
                                    h5("Reset Password",
                                        class = "text-bold text-center 
                                        text-body-1 pt-3"
                                    ),
                                    div(
                                        class = "card-body text-center",
                                        shiny::textInput(
                                            inputId = ns("reset_email"),
                                            label = "Email address",
                                            placeholder = "johndoe@example.com"
                                        ) |> make_input_required(),
                                        div(
                                            class = "d-flex justify-content-center",
                                            actionButton(
                                                inputId = reset_btn_id,
                                                label = "Reset",
                                                type = "submit",
                                                width = "300px",
                                                onclick = sprintf(
                                                    "disable_auth_btn('%s')", reset_btn_id
                                                )
                                            ) |> basic_primary_btn()
                                        )
                                    ),
                                    tags$div(
                                        class = "text-center",
                                        tags$p(
                                            class = "mt-3 small text-bold",
                                            "Want to retry?",
                                            actionLink(
                                                inputId = ns("back_to_login"),
                                                label = "Login"
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
}
