ui <- argonDash::argonDashPage(
  title = "CHEATSHEETS",
  description = "Course Description/Cheatsheet/Outline",
  author = "Jefferson Ndeke",
  header = argonDash::argonDashHeader(
    color = "default",
    argonR::argonImage(
      src = "logo/imac.svg",
      width = "50px"
    ),
    actionButton(
      inputId = "admin",
      label = "Administrator",
      icon = icon("user-tie")
    ) 
  ),
  argonDash::argonDashBody(
      div(
        shinybusy::add_busy_spinner(
          spin = "fading-circle",
          position = "top-right",
          margins = c("30%", "50%")
        )
      ),
      uiOutput("body_content")
)
)
