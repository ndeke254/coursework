#' Customize your sign in page UI with logos, text, and colors.
custom_sign_in_page <- sign_in_ui_default(
    color = "#1D2856",
    company_name = tags$head(
        tags$link(
            rel = "icon",
            type = "image/png",
            href = "logo/logo_header_.svg",
        ),
        tags$title("Keytabu")
    ),
    logo_top = tags$img(
        src = "logo/logo_header.png",
        style = "width: 200px; padding: 30px;"
    ),
    background_image = "logo/background_image.png",
     align = "right",
     footer_color = "#ffffff"
)

