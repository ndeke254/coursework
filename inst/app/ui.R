# ---- page ----
ui <- argonDash::argonDashPage(
  title = tags$head(
    tags$link(
      rel = "icon",
      type = "image/png",
      href = "logo/logo_header.png",
    ),
    tags$title("Keytabu")
  ),
  description = "Course Description/Cheatsheet/Outline",
  author = "Jefferson Ndeke",
  # --- header ----
  header = argonDashHeader(
    gradient = FALSE,
    background_img = "logo/header.png",
    height = 400,
    color = "translucent-info",
    div(
      class = "position-absolute font-weight-900",
      textOutput("selected_tab")
    ),
    argonDropNav(
      title = "Profile",
      orientation = "right",
      src = "logo/user_image.jpg",
      argonDropNavTitle(
        title = "Welcome"
      ),
      argonDropNavItem(
        title = "Edit Profile",
        src = "#",
        icon = argonIcon("ui-04")
      ),
      argonDropNavItem(
        title = "Log out",
        src = "#",
        icon = argonIcon("user-run")
      )
    )
  ),

  #---- sidebar ----
  sidebar = argonDash::argonDashSidebar(
    id = "sidebar",
    brand_logo = "logo/logo.png",
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
        icon = icon("home", class = "text-body")
      ),
      argonSidebarItem(
        "Registration",
        tabName = "registration",
        icon = argonIcon("single-copy-04", color = "body")
      ),
      argonSidebarItem(
        "Upload",
        tabName = "upload",
        icon = argonIcon("cloud-upload-96", color = "body")
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
        icon = argonIcon("books", color = "body")
      ),
      argonSidebarItem(
        "Cart",
        tabName = "cart",
        icon = argonIcon("cart", color = "body")
      ),
      argonSidebarItem(
        "Content",
        tabName = "student_content",
        icon = argonIcon("bullet-list-67", color = "body")
      ),
      argonSidebarItem(
        "Payments",
        tabName = "payments",
        icon = argonIcon("money-coins", color = "body")
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
        icon = icon("chalkboard-user", class = "text-body")
      ),
      argonSidebarItem(
        "Content",
        tabName = "teacher_content",
        icon = argonIcon("books", color = "body")
      ),
      argonSidebarItem(
        "Earnings",
        tabName = "earnings",
        icon = argonIcon("money-coins", color = "body")
      )
    ),
    # ----Developer ----
    argonSidebarDivider(),
    argonSidebarHeader(
      title = "DEVELOPER"
    ),
    argonSidebarMenu(
      argonSidebarItem(
        "Administrators",
        tabName = "administrators",
        icon = icon("shield", class = "text-body")
      )
    )
  ),
  # ---- body ----
  body = argonDash::argonDashBody(
    useSweetAlert(),
    div(
      class = "min-height-300 bg-primary position-absolute w-100"
    ),
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
    tags$head(
      tags$script(HTML("
    $(document).on('click', '.nav-link', function() {
      var activeTab =  $('.nav-link.active').attr('data-value');
      Shiny.setInputValue('active_sidebar_tab', activeTab);
    });
  "))
    ),
    # ---- admin ----
    argonTabItems(
      argonTabItem(
        tabName = "dashboard",
        "Dashboard Here"
      ),
      argonTabItem(
        tabName = "registration",
        admin_registration_tab
      ),
      argonTabItem(
        tabName = "upload",
        div(
          admin_upload_page
        )
      ),
      # ---- student ----
      argonTabItem(
        tabName = "student_content",
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
              actionButton("prev_btn", "", icon = icon("arrow-left"), class = "bg-gradient-gray") |> basic_primary_btn(),
              actionButton("full_screen_btn", "", icon = icon("expand"), class = "bg-gradient-gray") |> basic_primary_btn(),
              actionButton("next_btn", "", icon = icon("arrow-right"), class = "bg-gradient-gray") |> basic_primary_btn(),
              uiOutput("progress_bar")
            ),
            imageOutput("pdf_images", height = "auto", width = "100%")
          )
        )
      )
    )
  )
)
# secure_ui(ui)
