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
    shiny::tagList(
      tags$div(
        class = "d-flex float-right align-items-center p-2",
        tags$span(
          class = "mx-2 text-uppercase text-truncate w-75",
          textOutput("signed_user")
        ),
        shinyWidgets::dropdown(
          style = "unite",
          icon = argonIcon("single-02"),
          right = TRUE,
          size = "sm",
          animate = shinyWidgets::animateOptions(
            enter = shinyWidgets::animations$sliding_entrances$slideInDown,
            exit = shinyWidgets::animations$fading_exits$fadeOut,
            duration = 0.5
          ),
          shiny::actionButton(
            inputId = "user_profile_edit",
            label = "Edit Profile",
            icon = icon("user-pen"),
            width = "100%",
            class = "px-0 dropdown-item border-0 icon-link shadow"
          ),
          shiny::actionButton(
            inputId = "log_out_session",
            label = "Log Out",
            icon = icon("power-off"),
            width = "100%",
            class = "px-0 dropdown-item border-0 icon-link shadow"
          ),
        )
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
        uiOutput("published_pdfs"), # class = "d-flex flex-wrap"),
        argonR::argonModal(
          width = 12,
          id = "modal",
          title = "Selected Content",
          status = "secondary",
          gradient = TRUE,
          div(
            id = "modal-content",
            class = "hover-content",
            style = "position: relative;",
            div(
              id = "hover-div",
              class = "bg-translucent-default rounded pt-3 pb-3",
              actionButton(
                inputId = "prev_btn",
                label = "",
                icon = icon("arrow-left"),
                class = "bg-gradient-gray"
              ) |>
                basic_primary_btn(),
              actionButton(
                inputId = "full_screen_btn",
                label = "",
                icon = icon("expand"),
                class = "bg-gradient-gray"
              ) |>
                basic_primary_btn(),
              actionButton(
                inputId = "next_btn",
                label = "",
                icon = icon("arrow-right"),
                class = "bg-gradient-gray"
              ) |>
                basic_primary_btn(),
              uiOutput("progress_bar")
            ),
            imageOutput("pdf_images", height = "auto", width = "100%")
          )
        )
      )
    )
  )
)

secure_ui(ui)
