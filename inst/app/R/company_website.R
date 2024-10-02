company_website <- div(
  id = "website",
  style = "width: 100%; overflow-x: hidden;",
  div(
    class = "vh-100 bg-default align-content-center",
    id = "intro_page",
    `data-aos` = "fade-up",
    `data-aos-delay` = "100",
    div(
      div(
        style = "
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('logo/cover.png');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            opacity: 0.1;  /* Damped opacity */
        "
      ),
      style = "max-width: 1200px; margin: 0 auto;",
      fluidRow(
        class = "px-5",
        column(
          width = 4,
          div(
            class = "d-flex justify-content-center",
            tags$img(
              src = "logo/girl_tablet.png",
              width = "100%",
              style = "margin-top: 90px;
              background: radial-gradient(#F9D62E -72%, #00000000 70%);"
            )
          )
        ),
        column(
          width = 4,
          div(
            class = "h1 text-bold text-white mt-5 pt-5",
            "Learn Quick",
            br(),
            "Learn Smart",
            br(),
            "Learn Alot..."
          ),
          div(
            class = "p lead text-orange_1 pt-3 pb-4",
            "With High Quality, Quick Reference",
            br(),
            "Content for Students"
          ),
          div(
            actionButton(
              inputId = "register_now",
              label = "Register Now",
              class = "mt-5 mb-5",
              width = "230px"
            )
          )
        ),
        column(
          width = 4,
          div(
            class = "d-flex justify-content-center",
            tags$img(
              src = "inst/images/child_1.png",
              width = "100%",
              style = "max-width: 250px;
              background: radial-gradient(#fff -72%, #00000000 70%);"
            )
          )
        )
      )
    )
  ),
  div(
    id = "home_section",
    `data-aos` = "fade-up",
    `data-aos-delay` = "100",
    class = "bg-white",
    div(
      style = "
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image:url('logo/login_background.png');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            opacity: 0.1;  /* Damped opacity */
            mask-image: linear-gradient(to bottom, black 70%, transparent 100%);
        "
    ),
    div(
      style = "max-width: 1200px; margin: 0 auto;",
      fluidRow(
        class = "  px-4",
        column(
          width = 4,
          div(
            tags$img(
              src = "inst/images/teacher_1.png",
              width = "100%",
              style = "max-width: 430px; filter:
               drop-shadow(2px 4px 6px var(--primary));"
            )
          )
        ),
        column(
          width = 8,
          class = "pt-5",
          h1(
            class = "text-bold text-body_1",
            "What is Candidate?"
          ),
          tags$div(
            class = "lead pt-4",
            p(HTML("<em>Candidate</em> is an online library of revision material created by teachers for their students.")),
            p("That is worth repeating; the content is created by teachers to aid their own students in mastering what has been taught in class. And because the content is teacher-generated, it is highly focused on the identified needs of students."),
            p("These study guides are carefully created based on teachers' analysis of what their students need to master on both basic and advanced topics."),
            p(HTML("The revision material is intentionally made short (often limited to a page or two). Additionally, we emphasize the use of pictures and illustrations that complement traditional notes, enhancing both the understanding and retention of basic and advanced topics.")),
            p(HTML("As a final note, <em>Candidate</em> does not focus on exam preparation. We prefer the higher goal of helping students understand lessons at a deep and fundamental level."))
          ),
          div(
            class = "position-absolute pt-5  px-5",
            tags$img(
              src = "inst/images/arrow_left.png",
              width = "100%",
              style = "max-width: 100px; filter:
               drop-shadow(2px 4px 6px var(--primary));"
            )
          ),
          h5(
            class = "pb-5 mt-4 text-bold",
            "Are you a teacher?"
          ),
          column(
            width = 6,
            class = "pt-4",
            actionButton(
              inputId = "lets_partner",
              label = "Let's Partner",
              class = "mt-5 mb-5 fw-bold",
              width = "230px"
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
    class = "bg-gray-light",
    div(
      style = "max-width: 1200px; margin: 0 auto;",
      class = "pt-5 pb-5",
      h1(
        class = "text-bold text-body_1 text-center",
        "Content Categories"
      ),
      fluidRow(
        class = "pt-4",
        column(
          width = 4,
          class = "pb-2",
          div(
            class = "card shadow h-100",
            style = "overflow: hidden;",
            fluidRow(
              column(
                width = 1,
                class = "mt-3 mx-3",
                div(
                  class = "d-flex justify-content-center
                                         align-items-center shadow bg-default
                                          rounded-circle",
                  style = "width: 50px;
                                         height: 50px;",
                  bsicons::bs_icon(
                    name = "list-check",
                    size = "24px",
                    class = "text-white"
                  )
                )
              ),
              column(
                width = 10,
                div(
                  class = "mx-2 pt-4",
                  p(
                    class = "text-bold lead text-body_1",
                    "Subject Matter Review:"
                  ),
                  p(
                    "Condense summaries giving an
                                            overall view of subjects,
                                            highlighting main topics and
                                            concepts."
                  )
                )
              )
            )
          )
        ),
        column(
          width = 4,
          class = "pb-2",
          div(
            class = "card shadow h-100",
            style = "overflow: hidden;",
            fluidRow(
              column(
                width = 1,
                class = "mt-3 mx-3",
                div(
                  class = "d-flex justify-content-center
                                         align-items-center shadow bg-orange_1
                                         rounded-circle",
                  style = "width: 50px;
                                         height: 50px;",
                  bsicons::bs_icon(
                    name = "file-earmark-fill",
                    size = "24px",
                    class = "text-white"
                  )
                )
              ),
              column(
                width = 10,
                div(
                  class = "mx-2 pt-4",
                  p(
                    class = "text-bold lead text-orange_1",
                    "Topic Reviews:"
                  ),
                  p(
                    "In-depth 1-2 page reviews of
                                            specific topics, like introductory
                                            algebra, to reinforce key
                                            concepts."
                  )
                )
              )
            )
          )
        ),
        column(
          width = 4,
          class = "pb-2",
          div(
            class = "card shadow h-100",
            style = "overflow: hidden;",
            fluidRow(
              column(
                width = 1,
                class = "mt-3 mx-3",
                div(
                  class = "d-flex justify-content-center
                                         align-items-center shadow bg-secondary
                                         rounded-circle",
                  style = "width: 50px;
                                         height: 50px;",
                  bsicons::bs_icon(
                    name = "clipboard-check-fill",
                    size = "24px",
                    class = "text-white"
                  )
                )
              ),
              column(
                width = 10,
                div(
                  class = "mx-2 pt-4",
                  p(
                    class = "text-bold lead text-gray",
                    "Concept Checkers:"
                  ),
                  p(
                    "Focused materials diving deep into
                                            specific concepts, such as adding
                                            decimals with different
                                            denominators."
                  )
                )
              )
            )
          )
        )
      )
    )
  ),
  div(
    id = "about_us_section",
    `data-aos` = "fade-up",
    `data-aos-delay` = "100",
    class = "bg-white",
    div(
      style = "
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image:url('logo/cheatsheet.png');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            opacity: 0.1;  /* Damped opacity */
            mask-image: linear-gradient(to bottom, black 70%, transparent 100%);
        "
    ),
    div(
      style = "max-width: 1200px; margin: 0 auto;",
      fluidRow(
        class = "  px-4",
        column(
          width = 6,
          div(
            class = "d-flex pt-5",
            h1(
              class = "text-bold text-body_1",
              display = 5,
              "Our"
            ),
            h1(
              class = "text-bold text-orange_1 px-3",
              display = 5,
              "Mission"
            )
          ),
          fluidRow(
            p(
              class = "pt-3 lead",
              "We aim to provide a comprehensive online
                                resource of teacher-developed revision
                                materials, accessible 24/7, to support both
                                students and teachers in achieving
                                their learning goals. Parents can also engage
                                 with their child's learning journey by
                                 accessing important study materials."
            )
          ),
          div(
            class = "justify-content-end d-flex pt-5 ",
            div(
              tags$img(
                src = "inst/images/parent_student.png",
                width = "100%",
                style = "max-width: 700px; filter:
               drop-shadow(2px 4px 6px var(--primary));"
              )
            ),
            div(
              class = "position-absolute",
              tags$img(
                src = "inst/images/arrow_right.png",
                width = "100%",
                style = "max-width: 100px; filter:
               drop-shadow(2px 4px 6px var(--primary));"
              )
            )
          )
        ),
        column(
          width = 6,
          fluidRow(
            class = "justify-content-center",
            div(
              tags$img(
                src = "inst/images/child_2.png",
                width = "100%",
                style = "max-width: 400px; filter:
               drop-shadow(2px 4px 6px var(--primary));"
              )
            )
          ),
          fluidRow(
            div(
              class = "d-flex pt-5",
              h1(
                class = "text-bold text-body_1",
                "Our"
              ),
              h1(
                class = "text-bold text-orange_1 px-3",
                "Premise"
              )
            )
          ),
          fluidRow(
            p(
              class = "lead pt-3 pb-3",
              "With limited classroom time and varying
                                student learning speeds, traditional
                                methods may not suit everyone.
                                Candidate offers additional, tailored
                                learning materials that students can
                                access anytime, bridging gaps and
                                reinforcing classroom learning."
            )
          )
        )
      )
    )
  ),
  div(
    class = "bg-gray-light",
    id = "partners_page",
    `data-aos` = "fade-up",
    `data-aos-delay` = "100",
    div(
      class = "pt-5 pb-5   px-4",
      style = "max-width: 1200px; margin: 0 auto;",
      h1(
        class = "text-bold text-body_1 text-center",
        "Our Partners"
      ),
      div(
        class = "d-flex justify-content-center",
        tags$img(
          src = "inst/images/partners.png",
          width = "100%",
          style = "max-width: 1000px; filter:
               drop-shadow(2px 4px 6px var(--primary));"
        )
      )
    )
  ),
  div(
    class = "bg-white",
    id = "contact_us_section",
    `data-aos` = "fade-up",
    `data-aos-delay` = "100",
    div(
      style = "max-width: 1200px; margin: 0 auto;",
      fluidRow(
        class = "d-flex justify-content-center pt-5 pb-2",
        column(
          width = 4,
          class = "p-2 border-right",
          h1(
            class = "justify-content-center d-flex text-bold",
            "5M+"
          ),
          p(
            "Learners",
            class = "justify-content-center d-flex lead"
          )
        ),
        column(
          width = 4,
          class = "p-2 border-right",
          h1(
            class = "justify-content-center d-flex text-bold",
            "1000+"
          ),
          p(
            "Schools",
            class = "justify-content-center d-flex lead"
          )
        ),
        column(
          width = 4,
          class = "p-2 border-right",
          h1(
            class = "justify-content-center d-flex text-bold",
            "20"
          ),
          p(
            "Counties",
            class = "justify-content-center d-flex lead"
          )
        )
      ),
      fluidRow(
        class = "d-flex justify-content-center   px-4",
        div(
          class = "pb-5",
          actionButton(
            inputId = "register_now_1",
            label = "Register Now",
            class = "mt-5 fw-bold",
            width = "230px"
          )
        )
      )
    )
  ),
  div(
    class = "pt-5 bg-default text-center",
    id = "footer_section",
    div(
      style = "max-width: 1200px; margin: 0 auto;",
      fluidRow(
        class = "align-items-center   px-4",
        column(
          width = 6,
          tags$h1(
            class = "logo",
            tags$a(
              href = "",
              tags$img(
                src = file.path("logo", "logo_white.svg"),
                height = "100%",
                style = "max-height: 180px; filter:
               drop-shadow(2px 4px 6px var(--primary));"
              )
            )
          )
        ),
        column(
          width = 2,
          actionLink(
            inputId = "about_us_down",
            label = "About Us"
          )
        ),
        column(
          width = 2,
          actionLink(
            inputId = "contact_us",
            label = "Contact Us"
          )
        )
      ),
      tags$hr(
        class = "bg-gray"
      ),
      fluidRow(
        class = "align-items-center   px-4",
        column(
          width = 8,
          p(
            class = "text-white-50",
            "Copyright © 2024"
          ),
        ),
        column(
          width = 2,
          actionLink(
            inputId = "tos",
            label = "Terms & service"
          )
        ),
        column(
          width = 2,
          actionLink(
            inputId = "privacy_link",
            label = "Privacy Policy"
          )
        )
      )
    )
  )
)
