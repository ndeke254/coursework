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
                class = "card",
                # Card content
                tabsetPanel(
                    id = ns("auth_pages"),
                    type = "hidden",
                    selected = "login_page",
                    tabPanelBody(
                        value = "login_page",
                        div(
                            div(
                                title_icon = NULL,
                                tags$div(
                                    id = ns("auth_loader"),
                                    class = "auth_form_loader shinyjs-hide bg-default"
                                ),
                                div(
                                    class = "text-center pt-3 bg-light pb-2",
                                    tags$img(
                                        src = file.path("logo", "logo_icon_blue.png"),
                                        width = "70px"
                                    ),
                                    h5("Log in Candidate",
                                        class = "text-body-1 text-bold pt-3"
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
                            div(
                                title_icon = NULL,
                                tags$div(
                                    id = ns("authr_loader"),
                                    class = "auth_form_loader shinyjs-hide bg-default"
                                ),
                                tags$div(
                                    class = "text-center bg-light pb-2 pt-3",
                                    tags$img(
                                        src = file.path("logo", "logo_icon_blue.png"),
                                        width = "70px"
                                    ),
                                    h5("Reset Password",
                                        class = "text-bold text-center text-body-1 pt-3"
                                    )
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
}
