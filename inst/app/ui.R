# ----overall page ----
ui <- shiny::bootstrapPage(
  # Load dependencies and error items
  useSweetAlert(),
  firebase::useFirebase(),
  shinybusy::add_busy_spinner(
    spin = "fading-circle",
    position = "top-right",
    color = "#414042",
    margins = c("30%", "50%")
  ),
  shinyjs::useShinyjs(),
  includeCSS("www/css/styles.css"),
  includeScript("www/js/script.js"),
  tags$head(
    # Browser favicon:
    tags$link(
      rel = "shortcut icon",
      href = file.path("logo", "logo_icon.png")
    ),

    # General stylesheet:
    tags$link(
      rel = "stylesheet",
      href = file.path("css", "styles.css")
    ),

    # Bootstrap icons:
    tags$link(
      rel = "stylesheet",
      href = "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.3/font/bootstrap-icons.css"
    ),

    # AOS js:
    tags$link(
      href = "https://unpkg.com/aos@2.3.1/dist/aos.css",
      rel = "stylesheet"
    ),
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
  tags$a(
    href = "#",
    class = "back-to-top d-flex align-items-center justify-content-center",
    tags$i(class = "ni ni-bold-up")
  ),
  tags$script(
    src = "https://unpkg.com/aos@2.3.1/dist/aos.js"
  ),
  tags$script(
    src = file.path("js", "landing-page.js")
  ),
  tags$script(
    src = file.path("js", "main.js")
  ),
  tags$script(
    src = file.path("js", "script.js")
  ),
  shiny::tabsetPanel(
    id = "panels",
    type = "hidden",
    selected = "landing_page",
    tabPanelBody(
      value = "landing_page",
      tags$div(
        class = "fade-in",
        argonR::argonPage(
          title = "KEYTABU",

          # General stylesheet:
          tags$link(
            rel = "stylesheet",
            href = file.path("css", "styles.css")
          ),
          footer = argonFooter(
            status = "default",
            gradient = TRUE,
            argonContainer(
              size = "lg",
              argonRow(
                class = "align-items-center",
                argonColumn(
                  width = 8,
                  tags$h1(
                    class = "logo",
                    tags$a(
                      href = "",
                      tags$img(
                        src = file.path("logo", "logo_white.svg"),
                        height = "180px"
                      )
                    )
                  )
                ),
                argonColumn(
                  width = 2,
                  actionLink(
                    inputId = "about_us",
                    label = "About Us"
                  )
                ),
                argonColumn(
                  width = 2,
                  actionLink(
                    inputId = "contact_us",
                    label = "Contact Us"
                  )
                )
              ),
              tags$hr(
                class = "bg-white"
              ),
              argonRow(
                class = "align-items-center",
                argonColumn(
                  width = 8,
                  p(
                    display = 1,
                    "Copyright © 2024"
                  ) %>%
                    argonTextColor(
                      color = "white"
                    )
                ),
                argonColumn(
                  width = 2,
                  actionLink(
                    inputId = "tos",
                    label = "Terms & service"
                  )
                ),
                argonColumn(
                  width = 2,
                  actionLink(
                    inputId = "privacy_link",
                    label = "Privacy Policy"
                  )
                )
              )
            )
          ),
          # --- main ----
          div(
            id = "main",
            `data-aos` = "fade-up",
            `data-aos-delay` = "100",
            argonSection(
              status = "default",
              gradient = TRUE,
              class = "mt--100 pt-5",
              argonRow(
                center = TRUE,
                argonColumn(
                  width = 3,
                  tags$h1(
                    class = "logo",
                    tags$a(
                      href = "",
                      tags$img(
                        src = file.path("logo", "logo_white.svg"),
                        height = "180px"
                      )
                    )
                  )
                ),
                argonColumn(
                  width = 3,
                  actionLink(
                    inputId = "home_link",
                    label = "Home"
                  )
                ),
                argonColumn(
                  width = 3,
                  actionLink(
                    inputId = "about_us",
                    label = "About Us"
                  )
                ),
                argonColumn(
                  width = 3,
                  actionLink(
                    inputId = "log_link",
                    label = "Sign In"
                  )
                ),

                # right menu
                argonColumn(
                  width = 6,
                  class = "left-xl row",
                  argonNavMenu(
                    side = "right",
                    argonNavItem(
                      name = "facebook",
                      src = "https://www.facebook.com",
                      icon = icon("facebook-square"),
                      tooltip = "Facebook"
                    ),
                    argonNavItem(
                      name = "instagram",
                      src = "https://www.instagram.com",
                      icon = icon("instagram"),
                      tooltip = "Instagram"
                    ),
                    argonNavItem(
                      name = "twitter",
                      src = "https://www.twitter.com",
                      icon = icon("twitter-square"),
                      tooltip = "Twitter"
                    ),
                    argonNavItem(
                      name = "tiktok",
                      src = "https://www.tiktok.com",
                      icon = icon("tiktok"),
                      tooltip = "Tiktok"
                    )
                  )
                )
              ),
              div(
                id = "intro_page",
                `data-aos` = "fade-up",
                `data-aos-delay` = "100",
                argonColumn(
                  argonRow(
                    argonColumn(
                      width = 6,
                      div(
                        class = "pt-100",
                        argonH1(
                          display = 1,
                          "Learn Quick",
                          br(),
                          "Learn Smart",
                          br(),
                          "Learn Alot..."
                        ) %>%
                          argonTextColor(
                            color = "white"
                          ),
                        argonLead(
                          "With High Quality, Quick Reference",
                          br(),
                          "Content for Students"
                        ) %>%
                          argonTextColor(
                            color = "orange"
                          )
                      )
                    ),
                    argonColumn(
                      width = 8,
                      div(
                        class = "mt--100 mx-5",
                        argonImage(
                          src = "inst/images/child_1.png",
                          floating = TRUE,
                          width = "400px"
                        ) %>%
                          argonBlur(
                            text = "Register and select your grade",
                            text_color = "white"
                          )
                      )
                    )
                  ),
                  actionButton(
                    inputId = "register_now",
                    label = "Register now",
                    icon = argonIcon("bold-right")
                  )
                ) %>% argonPadding(
                  orientation = "x",
                  value = 0
                )
              )
            ),
            div(
              id = "explanation_page",
              `data-aos` = "fade-up",
              `data-aos-delay` = "100",
              argonSection(
                status = "white",
                argonRow(
                  argonColumn(
                    width = 5,
                    div(
                      class = "mt--100",
                      argonImage(
                        src = "inst/images/teacher_1.png",
                        floating = TRUE,
                        width = "500px"
                      ) %>%
                        argonBlur(
                          text = "Send handwritten content via photo
(WhatsApp or email)",
                          text_color = "default"
                        )
                    )
                  ),
                  argonColumn(
                    width = 8,
                    class = "mx-xl-lg",
                    argonH1(
                      display = 1,
                      "What is Keytabu?"
                    ) %>%
                      argonTextColor(
                        color = "default"
                      ),
                    argonLead("Keytabu is an online learning platform that partners with teachers to create a
digital library of revision materials. These include quick study guides, reference
notes, and ﬂashcards, all designed to enhance visual learning and aid retention.") %>%
                      argonTextColor(
                        color = "#414042"
                      ),
                    br(),
                    argonLead("These study guides are carefully created based on teachers' analysis of what their students need to master on both basic and advanced topics") %>%
                      argonTextColor(
                        color = "#414042"
                      ),
                    argonColumn(
                      width = 6,
                      div(
                        class = "position-absolute right-lg top-md",
                        argonImage(
                          src = "inst/images/arrow_left.png",
                          width = "100px"
                        )
                      )
                    ),
                    argonLead(
                      class = "font-weight-900 pb-100 mt-4",
                      "Are you a teacher?"
                    ) %>%
                      argonTextColor(
                        color = "default"
                      ),
                    argonColumn(
                      width = 3,
                      actionButton(
                        inputId = "lets_partner",
                        label = "Let's Partner",
                        icon = icon("hand-pointer")
                      )
                    )
                  )
                )
              )
            ),
            div(
              id = "cards_page",
              `data-aos` = "fade-up",
              `data-aos-delay` = "100",
              argonSection(
                status = "secondary",
                argonRow(
                  center = TRUE,
                  argonH1(
                    display = 1,
                    "Content Categories"
                  ) %>%
                    argonTextColor(
                      color = "default"
                    )
                ),
                argonRow(
                  argonColumn(
                    width = 4,
                    argonCard(
                      width = 12,
                      shadow = TRUE,
                      shadow_size = "sm",
                      hover_lift = TRUE,
                      hover_shadow = TRUE,
                      argonRow(
                        argonIconWrapper(
                          iconTag = argonIcon(
                            name = "bullet-list-67",
                            color = "white"
                          ),
                          status = "default",
                          gradient_color = "navy blue",
                          shadow = TRUE,
                          hover_shadow = TRUE
                        ),
                        argonColumn(
                          p(
                            class = "font-weight-900",
                            "Subject Matter Review:"
                          ) %>%
                            argonTextColor(
                              color = "default"
                            ),
                          p(
                            "Condense summaries giving an overall view of subjects, highlighting main topics and concepts."
                          ) %>%
                            argonTextColor(
                              color = "#414042"
                            )
                        )
                      )
                    )
                  ),
                  argonColumn(
                    width = 4,
                    class = "card-deck",
                    argonCard(
                      width = 12,
                      shadow = TRUE,
                      shadow_size = "sm",
                      hover_lift = TRUE,
                      hover_shadow = TRUE,
                      argonRow(
                        argonIconWrapper(
                          iconTag = argonIcon(
                            name = "like-2",
                            color = "white"
                          ),
                          status = "warning",
                          shadow = TRUE,
                          hover_shadow = TRUE
                        ),
                        argonColumn(
                          p(
                            class = "font-weight-900",
                            "Topic Reviews:"
                          ) %>%
                            argonTextColor(
                              color = "warning"
                            ),
                          p(
                            "In-depth 2-3 page reviews of specific topics, like introductory algebra, to reinforce key concepts."
                          ) %>%
                            argonTextColor(
                              color = "#414042"
                            )
                        )
                      )
                    )
                  ),
                  argonColumn(
                    width = 4,
                    argonCard(
                      width = 12,
                      shadow = TRUE,
                      shadow_size = "sm",
                      hover_lift = TRUE,
                      hover_shadow = TRUE,
                      argonRow(
                        argonIconWrapper(
                          iconTag = argonIcon(
                            name = "check-bold",
                            color = "white"
                          ),
                          status = "primary",
                          shadow = TRUE,
                          hover_shadow = TRUE
                        ),
                        argonColumn(
                          p(
                            class = "font-weight-900",
                            "Concept Checkers:"
                          ) %>%
                            argonTextColor(
                              color = "primary"
                            ),
                          p(
                            "Focused materials diving deep into specific concepts, such as adding decimals with different denominators."
                          ) %>%
                            argonTextColor(
                              color = "#414042"
                            )
                        )
                      )
                    )
                  )
                )
              )
            ),
            div(
              id = "about_page",
              `data-aos` = "fade-up",
              `data-aos-delay` = "100",
              argonSection(
                status = "white",
                argonRow(
                  argonColumn(
                    width = 6,
                    argonRow(
                      argonH1(
                        display = 1,
                        "Our"
                      ) %>%
                        argonTextColor(
                          color = "default"
                        ),
                      argonH1(
                        class = "px-3",
                        display = 1,
                        "Mission"
                      ) %>%
                        argonTextColor(
                          color = "warning"
                        )
                    ),
                    argonRow(
                      argonLead(
                        "We aim to provide a comprehensive online resource of teacher-developed revision
materials, accessible 24/7, to support both students and teachers in achieving
their learning goals. Parents can also engage with their child's learning journey by
accessing important study materials."
                      ) %>%
                        argonTextColor(
                          color = "#414042"
                        )
                    ),
                    argonRow(
                      div(
                        class = "position-absolute right-0",
                        argonImage(
                          src = "inst/images/arrow_right.png",
                          width = "100px"
                        )
                      ),
                      argonImage(
                        src = "inst/images/parent_student.png",
                        floating = TRUE,
                        width = "500px"
                      ) %>%
                        argonBlur(
                          text = "Monitor your child's progress",
                          text_color = "default"
                        )
                    )
                  ),
                  argonColumn(
                    width = 6,
                    class = "mx-xl-lg",
                    argonRow(
                      div(
                        class = "mt--200",
                        argonImage(
                          src = "inst/images/child_2.png",
                          floating = TRUE,
                          width = "400px"
                        ) %>%
                          argonBlur(
                            text = "Online classroom",
                            text_color = "default"
                          )
                      )
                    ),
                    argonRow(
                      argonH1(
                        display = 1,
                        class = "mt-5",
                        "Our"
                      ) %>%
                        argonTextColor(
                          color = "default"
                        ),
                      argonH1(
                        class = "px-3 mt-5",
                        display = 1,
                        "Premise"
                      ) %>%
                        argonTextColor(
                          color = "warning"
                        )
                    ),
                    argonRow(
                      argonLead(
                        "With limited classroom time and varying
student learning speeds, traditional
methods may not suit everyone.
Keytabu offers additional, tailored
learning materials that students can
access anytime, bridging gaps and
reinforcing classroom learning."
                      ) %>%
                        argonTextColor(
                          color = "#414042"
                        )
                    )
                  )
                )
              )
            ),
            div(
              id = "partners_page",
              `data-aos` = "fade-up",
              `data-aos-delay` = "100",
              argonSection(
                size = "lg",
                status = "secondary",
                cascade = TRUE,
                argonH1(
                  display = 1,
                  "Our Partners"
                ) %>%
                  argonPadding(orientation = "l", value = 5) %>%
                  argonPadding(orientation = "b", value = 5) %>%
                  argonTextColor(color = "default"),
                argonCascade(
                  argonCascadeItem(
                    name = "book-bookmark",
                    src = "https://www.google.com"
                  ),
                  argonCascadeItem(
                    name = "badge",
                    size = "sm"
                  ),
                  argonCascadeItem(
                    name = "bag-17",
                    size = "sm"
                  ),
                  argonCascadeItem(
                    name = "paper-diploma",
                    size = "sm"
                  ),
                  argonCascadeItem(
                    name = "bag-17",
                    src = "https://www.google.com"
                  ),
                  argonCascadeItem(
                    name = "books"
                  ),
                  argonCascadeItem(
                    name = "hat-3"
                  ),
                  argonCascadeItem(
                    name = "briefcase-24",
                    size = "sm", "https://www.google.com"
                  ),
                  argonCascadeItem(
                    name = "trophy",
                    size = "sm"
                  ),
                  argonCascadeItem(
                    name = "single-copy-04",
                    size = "sm"
                  ),
                  argonCascadeItem(
                    name = "collection"
                  ),
                  argonCascadeItem(
                    name = "ungroup"
                  ),
                  argonCascadeItem(
                    name = "chart-bar-32"
                  )
                )
              )
            ),
            div(
              id = "stats_page",
              `data-aos` = "fade-up",
              `data-aos-delay` = "100",
              argonSection(
                status = "white",
                argonRow(
                  class = "justify-content-around",
                  argonColumn(
                    class = "border-right border-default",
                    width = 3,
                    center = TRUE,
                    argonH1(
                      display = 1,
                      "5M+"
                    ) %>%
                      argonTextColor("default"),
                    argonLead(
                      "Learners"
                    )
                  ),
                  argonColumn(
                    class = "border-right border-default",
                    width = 3,
                    center = TRUE,
                    argonH1(
                      display = 1,
                      "1000+"
                    ) %>%
                      argonTextColor("default"),
                    argonLead(
                      "Schools"
                    )
                  ),
                  argonColumn(
                    width = 3,
                    center = TRUE,
                    argonH1(
                      display = 1,
                      "20"
                    ) %>%
                      argonTextColor("default"),
                    argonLead(
                      "Counties"
                    )
                  )
                ),
                argonRow(
                  center = TRUE,
                  class = "pt-5",
                  actionButton(
                    inputId = "register_now_1",
                    label = "Register Now",
                    icon = argonIcon("bold-right")
                  )
                )
              )
            )
          )
        )
      )
    ),

    # login page ----
    tabPanelBody(
      value = "signin_page",
      tags$div(
        class = "fade-in bg-default",
        mod_landing_page_ui(id = "landing_page"),
      )
    ),

    # dashboardpage----
    tabPanelBody(
      value = "dashboardpage_panel",
      tags$div(
        class = "fade-in bg-default",
        dashboard_page()
      )
    )
  )
)
