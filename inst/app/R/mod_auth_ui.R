#' Authentication module UI
#'
#' @param id Module id
mod_auth_ui <- \(id) {
    ns <- NS(id)
    reset_btn_id <- ns("reset_password_btn")

    tagList(
        tags$head(
            tags$style(HTML("
     /* Full-screen background with gradient and animation */
        body, html {
          height: 100%;
          margin: 0;
          font-family: Arial, Helvetica, sans-serif;
          background: linear-gradient(-45deg, #ee7752,
          #e73c7e, #23a6d5, #23d5ab);
          background-size: 400% 400%;
          animation: gradientBG 15s ease infinite;
        }

        /* Center the card on the page */
        .centered-container {
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          padding: 15px; /* Padding for small screens */
        }

       .split-card {
          display: flex;
          flex-direction: row;
          width: 100%;
          max-width: 800px;
          height: auto;
          border-radius: 10px;
          box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.2);
          overflow: hidden;
          background-color: white;
        }

        /* Left side with image */
        .split-card-left {
          width: 50%;
          background: url('logo/girl_child.png') no-repeat center center;
          background-size: cover;
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

        # Centered card layout
        div(
            class = "centered-container",
            div(
                class = "split-card",

                # Left side with background image
                div(class = "split-card-left"),

                # Right side with form
                div(
                    class = "split-card-right",
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
                                    #                    class = "card",
                                    tags$div(
                                        id = ns("auth_loader"),
                                        class = "auth_form_loader shinyjs-hide bg-default"
                                    ),
                                    tags$div(
                                        class = "bg-light rounded d-flex
                             justify-content-center",
                                        tags$img(
                                            src = file.path("logo", "logo.png"),
                                            width = "100px"
                                        )
                                    ),
                                    h5("Log in Keytabu",
                                        class = "bg-light text-bold
                             text-center pb-3"
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
                                    #     class = "card",
                                    tags$div(
                                        id = ns("authr_loader"),
                                        class = "auth_form_loader shinyjs-hide bg-default"
                                    ),
                                    tags$div(
                                        class = "bg-light rounded d-flex justify-content-center",
                                        tags$img(
                                            src = file.path("logo", "logo.png"),
                                            width = "100px"
                                        )
                                    ),
                                    h5("Reset Password",
                                        class = "bg-light text-bold
                             text-center pb-3"
                                    ),
                                    div(
                                        class = "card-body",
                                        shiny::textInput(
                                            inputId = ns("reset_email"),
                                            label = "Email address",
                                            placeholder = "johndoe@example.com"
                                        ) |> make_input_required(),
                                        actionButton(
                                            inputId = reset_btn_id,
                                            label = "Reset",
                                            type = "submit",
                                            width = "300px",
                                            onclick = sprintf(
                                                "disable_auth_btn('%s')", reset_btn_id
                                            )
                                        ) |> basic_primary_btn()
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
