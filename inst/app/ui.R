# ---- page ----
ui <- argonDash::argonDashPage(
  title = "CHEATSHEETS",
  description = "Course Description/Cheatsheet/Outline",
  author = "Jefferson Ndeke",
  #--- header ----
  # header = argonDashHeader(
  #  color = "default",
  #  class = "pb-3 pt-3",
  #   argonDropNav(
  #    orientation = "right",
  #   title = "Profile",
  #  argonDropNavTitle(
  #   title = "Status"
  # ),
  # argonDropNavItem(
  #  title = "Edit Profile",
  # src = "#",
  # icon = argonIcon("user-pen", color = "success")
  # ),
  # argonDropNavItem(
  # title = "Log Out",
  # src = "#",
  #   icon = argonIcon("power-off", color = "success")
  # )
  # )
  #  ),
  #---- sidebar ----
  sidebar = argonDash::argonDashSidebar(
    id = "sidebar",
    brand_logo = "logo/imac.svg",
    size = "lg",
    background = "secondary",
    # ---- admin ----
    argonSidebarDivider(),
    argonSidebarHeader(
      title = "ADMINISTRATOR"
    ),
    argonSidebarMenu(
      argonSidebarItem(
        "Dashboard",
        tabName = "dashboard",
        icon = argonIcon("align-left-2", color = "success")
      ),
      argonSidebarItem(
        "Registration",
        tabName = "registration",
        icon = argonIcon("single-copy-04", color = "success")
      ),
      argonSidebarItem(
        "Upload",
        tabName = "upload",
        icon = argonIcon("cloud-upload-96", color = "success")
      )
    ),
    #---- Student ----
    argonSidebarDivider(),
    argonSidebarHeader(
      title = "STUDENT"
    ),
    argonSidebarMenu(
      argonSidebarItem(
        "Subscriptions",
        tabName = "subscriptions",
        icon = argonIcon("books", color = "success")
      ),
      argonSidebarItem(
        "Cart",
        tabName = "cart",
        icon = argonIcon("cart", color = "success")
      ),
      argonSidebarItem(
        "Content",
        tabName = "student_content",
        icon = argonIcon("bullet-list-67", color = "success")
      ),
      argonSidebarItem(
        "Payments",
        tabName = "payments",
        icon = argonIcon("money-coins", color = "success")
      )
    ),
    # ----Teacher ----
    argonSidebarDivider(),
    argonSidebarHeader(
      title = "TEACHER"
    ),
    argonSidebarMenu(
      argonSidebarItem(
        "Students",
        tabName = "students",
        icon = icon("chalkboard-user", class = "text-success")
      ),
      argonSidebarItem(
        "Content",
        tabName = "teacher_content",
        icon = argonIcon("books", color = "success")
      ),
      argonSidebarItem(
        "Earnings",
        tabName = "earnings",
        icon = argonIcon("money-coins", color = "success")
      )
    )
  ),
  # ---- body ----
  body = argonDash::argonDashBody(
    div(
      shinybusy::add_busy_spinner(
        spin = "fading-circle",
        position = "top-right",
        margins = c("30%", "50%")
      )
    ),
    shinyjs::useShinyjs(),
    includeCSS(
      path = "www/css/styles.css"
    ),
    includeScript(
      path = "www/js/script.js"
    ),
    # ---- admin ----
    argonTabItems(
      argonTabItem(
        tabName = "dashboard",
        "here dashboard"
      ),
      argonTabItem(
        tabName = "registration",
        admin_registration_tab
      ),
      argonTabItem(
        tabName = "upload",
      admin_upload_page
      ),
      # ---- student ----
      argonTabItem(
        tabName = "content",
        uiOutput("published_pdfs", class = "d-flex flex-wrap"),
        argonR::argonModal(
          width = 12,
          id = "modal",
          title = "Selected Content",
          status = "secondary",
          gradient = TRUE,
          div(
            id = "modal-content",
            class = "hover-content", # Apply the hover class to the modal content
            style = "position: relative;", # Ensure the modal content is relatively positioned
            div(
              id = "hover-div",
              class = "bg-translucent-default rounded pt-3 pb-3",
              actionButton("prev_btn", "", icon = icon("arrow-left"), class = "bg-gradient-gray") |> remove_btn_default(),
              actionButton("full_screen_btn", "", icon = icon("expand"), class = "bg-gradient-gray") |> remove_btn_default(),
              actionButton("next_btn", "", icon = icon("arrow-right"), class = "bg-gradient-gray") |> remove_btn_default(),
              uiOutput("progress_bar")
            ),
            imageOutput("pdf_images", height = "auto", width = "100%")
          )
        )
      )
    )
  )
)
