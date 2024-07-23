# ----overall page ----
ui <- argonPage(
  useSweetAlert(),
  shinybusy::add_busy_spinner(
    spin = "fading-circle",
    position = "top-right",
    margins = c("30%", "50%")
  ),
  shinyjs::useShinyjs(),
  includeCSS("www/css/styles.css"),
  includeScript("www/js/script.js"),
  tags$head(
    tags$script(HTML("
        Shiny.addCustomMessageHandler('update-tabs', function(message) {
          var currentTab = message;
          console.log('Switching to tab:', currentTab);

          // Hide and deactivate all not selected tabs
          $('.nav-item .nav-link').removeClass('active');
          $('.tab-content .tab-pane').removeClass('active show');

          // Add active class to the current selected tab and show its content
          $('#tab-' + currentTab).addClass('active');
          $('#shiny-tab-' + currentTab).addClass('active show');
        });

        $(document).on('click', '.nav-link', function() {
          var activeTab = $(this).attr('data-value');
          Shiny.setInputValue('active_sidebar_tab', activeTab);
        });
      "))
  ),

  # ---- Landing Page ----
  shinyjs::hidden(
    div(
      id = "landing_page",
      class = "fade-in"
    )
  ),

  # ---- Dashboard Page ----
  shinyjs::hidden(
    div(
      id = "dashboard_page",
      class = "fade-in",
      argonDash::argonDashPage(
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
          user_profile_tab
        ),
        # ---- sidebar ----
        sidebar = argonDash::argonDashSidebar(
          id = "sidebar",
          brand_logo = "logo/logo.png",
          size = "lg",
          background = "secondary",
          shinyjs::hidden(
            div(
              id = "admin_sidebar",
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
                ),
                argonSidebarItem(
                  "Payments",
                  tabName = "admin_payments",
                  icon = icon("sack-dollar")
                )
              )
            )
          ),
          shinyjs::hidden(
            div(
              id = "student_sidebar",
              #---- Student ----
              argonSidebarDivider(),
              argonSidebarHeader(
                title = "STUDENT"
              ),
              argonSidebarMenu(
                argonSidebarItem(
                  "Content",
                  tabName = "content",
                  icon = argonIcon("bullet-list-67", color = "body")
                ),
                argonSidebarItem(
                  "Payments",
                  tabName = "payments",
                  icon = argonIcon("money-coins", color = "body")
                )
              )
            )
          ),
          shinyjs::hidden(
            div(
              id = "teacher_sidebar",
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
                  tabName = "work",
                  icon = argonIcon("books", color = "body")
                ),
                argonSidebarItem(
                  "Earnings",
                  tabName = "earnings",
                  icon = argonIcon("money-coins", color = "body")
                )
              )
            )
          ),
          shinyjs::hidden(
            div(
              id = "developer_sidebar",
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
            )
          )
        ),
        # ---- body ----
        body = argonDash::argonDashBody(
          # ---- admin ----
          argonTabItems(
            argonTabItem(
              tabName = "dashboard",
              dashboard_user_content
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
              student_content_tab
            ),
            argonTabItem(
              tabName = "admin_payments",
              argonR::argonCard(
                title = "Create a payment ticket",
                shadow = TRUE,
                border_level = 5,
                icon = icon("credit-card"),
                status = "default",
                width = 12,
                uiOutput("paid_tickets")
              )
            ),
            argonTabItem(
              tabName = "payments",
              argonR::argonCard(
                title = "Create a payment ticket",
                shadow = TRUE,
                border_level = 5,
                icon = icon("credit-card"),
                status = "default",
                width = 12,
                p("Capture payment details correctly", class = "mt--2 text-muted"),
                argonRow(
                  center = TRUE,
                  argonColumn(
                    width = 3,
                    shiny::textInput(
                      inputId = "transaction_code",
                      label_mandatory("Transaction code:"),
                      value = "",
                      placeholder = "Eg. SGE8NAJFVU"
                    )
                  ),
                  argonColumn(
                    width = 3,
                    autonumericInput(
                      inputId = "amount",
                      label_mandatory("Amount:"),
                      value = 1000,
                      currencySymbol = "Ksh ",
                      decimalPlaces = 0,
                      minimumValue = 500
                    )
                  ),
                  argonColumn(
                    width = 3,
                    autonumericInput(
                      inputId = "tel_number",
                      label_mandatory("Phone:"),
                      value = 123456789,
                      currencySymbol = "254 ",
                      decimalPlaces = 0,
                      digitGroupSeparator = ""
                    )
                  ),
                  argonColumn(
                    width = 3,
                    airDatepickerInput(
                      inputId = "payment_time",
                      label = label_mandatory("Date/Time"),
                      timepicker = TRUE,
                      separator = "/",
                      placeholder = "Eg. 10/7/24 3:13 PM",
                      dateFormat = "d/M/yy",
                      maxDate = lubridate::today(),
                      startView = NULL,
                      clearButton = TRUE,
                      autoClose = TRUE,
                      addonAttributes = list(
                        class = "btn-circle"
                      ),
                      timepickerOpts = timepickerOptions(
                        timeFormat = "h:mm AA"
                      )
                    )
                  )
                ),
                argonRow(
                  center = TRUE,
                  class = "mt-5 float-right",
                  shiny::actionButton(
                    inputId = "create_ticket",
                    label = "Add",
                    icon = icon("plus-circle"),
                    class = "px-5"
                  ) |>
                    basic_primary_btn()
                ),
                argonRow(
                  class = "mt-5",
                  uiOutput("payments_data")
                )
              )
            )
          )
        )
      )
    )
  )
)

secure_ui(ui, custom_sign_in_page)
