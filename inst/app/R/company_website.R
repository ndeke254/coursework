company_website <- div(
    id = "website",
    `data-aos` = "fade-up",
    `data-aos-delay` = "100",
    argonSection(
        status = "default",
        class = "pt-5",
        div(
            id = "intro_page",
            `data-aos` = "fade-up",
            `data-aos-delay` = "100",
            argonColumn(
                argonRow(
                    argonColumn(
                        width = 4,
                        div(
                            id = "sign_in_container",
                            class = "pt-100",
                            argonH1(
                                display = 3,
                                class = "fw-bold",
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
                                class = "pt-3 pb-5",
                                "With High Quality, Quick Reference",
                                br(),
                                "Content for Students"
                            ) %>%
                                argonTextColor(
                                    color = "body"
                                ),
                            div(
                                actionButton(
                                    inputId = "register_now",
                                    label = "Register Now",
                                    class = "mt-5 fw-bold",
                                    width = "230px"
                                )
                            )
                        )
                    ),
                    argonColumn(
                        width = 8,
                        div(
                            class = "d-flex justify-content-center",
                            argonImage(
                                src = "inst/images/child_3.png",
                                floating = TRUE,
                                width = "779px"
                            )
                        )
                    )
                )
            )
        )
    ),
    argonSection(
        status = "white",
        div(
            id = "home_section",
            `data-aos` = "fade-up",
            `data-aos-delay` = "100",
            fluidRow(
                column(
                    width = 5,
                    class = "px-5",
                    div(
                        argonImage(
                            src = "inst/images/teacher_1.png",
                            floating = TRUE,
                            width = "500px"
                        )
                    )
                ),
                column(
                    width = 7,
                    class = "px-5 pt-5",
                    argonH1(
                        display = 5,
                        class = "fw-bold",
                        "What is Keytabu?"
                    ),
                    argonLead(
                        class = "pt-4",
                        "Keytabu is an online learning platform that partners with teachers to create a
                    digital library of revision materials. These include quick
                    study guides, reference notes, and flashcards, all designed to enhance visual learning and aid retention."
                    ) %>%
                        argonTextColor(
                            color = "black"
                        ),
                    br(),
                    argonLead("These study guides are carefully created based on teachers' analysis of what their students need to master on both basic and advanced topics") %>%
                        argonTextColor(
                            color = "black"
                        ),
                    column(
                        width = 6,
                        div(
                            class = "position-absolute mx-5 pt-5 px-5",
                            argonImage(
                                src = "inst/images/arrow_left.png",
                                width = "100px"
                            )
                        )
                    ),
                    argonLead(
                        class = "pb-5 mt-4 fw-semibold",
                        "Are you a teacher?"
                    ) %>%
                        argonTextColor(
                            color = "black"
                        ),
                    column(
                        width = 6,
                        actionButton(
                            inputId = "lets_partner",
                            label = "Let's Partner",
                            class = "mt-5 fw-bold",
                            width = "230px"
                        )
                    )
                )
            )
        )
    ),
    argonSection(
        status = "body-secondary",
        div(
            id = "cards_page",
            `data-aos` = "fade-up",
            `data-aos-delay` = "100",
            div(
                status = "secondary",
                class = "pt-5 pb-5",
                fluidRow(
                    center = TRUE,
                    argonH1(
                        class = "d-flex justify-content-center fw-bold",
                        display = 5,
                        "Content Categories"
                    )
                ),
                fluidRow(
                    class = "pt-4",
                    column(
                        width = 4,
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
                                        argonLead(
                                            class = "fw-semibold text-body_1",
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
                                        argonLead(
                                            class = "fw-semibold text-body",
                                            "Topic Reviews:"
                                        ),
                                        p(
                                            "In-depth 2-3 page reviews of
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
                                        argonLead(
                                            class = "fw-semibold
                                            text-body-secondary",
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
        )
    ),
    argonSection(
        status = "white",
        div(
            id = "about_us_section",
            `data-aos` = "fade-up",
            `data-aos-delay` = "100",
            div(
                status = "white",
                class = "pb-5",
                fluidRow(
                    column(
                        width = 6,
                        div(
                            class = "d-flex pt-5",
                            argonH1(
                                class = "fw-bold",
                                display = 5,
                                "Our"
                            ),
                            argonH1(
                                class = "fw-bold text-body px-3",
                                display = 5,
                                "Mission"
                            )
                        ),
                        fluidRow(
                            argonLead(
                                class = "text-black pt-3",
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
                                argonImage(
                                    src = "inst/images/parent_student.png",
                                    floating = TRUE,
                                    width = "700px"
                                )
                            ),
                            div(
                                class = "position-absolute",
                                argonImage(
                                    src = "inst/images/arrow_right.png",
                                    width = "100px"
                                )
                            )
                        )
                    ),
                    column(
                        width = 6,
                        class = "px-5",
                        fluidRow(
                            div(
                                argonImage(
                                    src = "inst/images/child_2.png",
                                    floating = TRUE,
                                    width = "400px"
                                )
                            )
                        ),
                        fluidRow(
                            div(
                                class = "d-flex pt-5",
                                argonH1(
                                    class = "fw-bold",
                                    display = 5,
                                    "Our"
                                ),
                                argonH1(
                                    class = "fw-bold text-body px-3",
                                    display = 5,
                                    "Premise"
                                )
                            )
                        ),
                        fluidRow(
                            argonLead(
                                class = "text-black pt-3",
                                "With limited classroom time and varying
                                student learning speeds, traditional
                                methods may not suit everyone.
                                Keytabu offers additional, tailored
                                learning materials that students can
                                access anytime, bridging gaps and
                                reinforcing classroom learning."
                            )
                        )
                    )
                )
            )
        )
    ),
    argonSection(
        status = "body-secondary",
        div(
            id = "partners_page",
            `data-aos` = "fade-up",
            `data-aos-delay` = "100",
            div(
                status = "secondary",
                class = "pt-5 pb-5",
                fluidRow(
                    center = TRUE,
                    argonH1(
                        class = "d-flex justify-content-center fw-bold",
                        display = 5,
                        "Our Partners"
                    )
                ),
                fluidRow(
                    center = TRUE,
                    div(
                        class = "d-flex justify-content-center",
                        argonImage(
                            src = "inst/images/partners.png",
                            floating = TRUE,
                            width = "1000px"
                        )
                    )
                )
            )
        )
    ),
    argonSection(
        status = "white",
        div(
            id = "contact_us_section",
            `data-aos` = "fade-up",
            `data-aos-delay` = "100",
            div(
                status = "white",
                fluidRow(
                    class = "d-flex justify-content-end pt-5 pb-2",
                    column(
                        width = 3,
                        center = TRUE,
                        argonH1(
                            class = "fw-bold",
                            display = 5,
                            "5M+"
                        ),
                        argonLead(
                            "Learners"
                        )
                    ),
                    column(
                        width = 3,
                        center = TRUE,
                        argonH1(
                            class = "fw-bold",
                            display = 5,
                            "1000+"
                        ),
                        argonLead(
                            "Schools"
                        )
                    ),
                    column(
                        width = 3,
                        center = TRUE,
                        argonH1(
                            class = "fw-bold",
                            display = 5,
                            "20"
                        ),
                        argonLead(
                            "Counties"
                        )
                    )
                ),
                fluidRow(
                    center = TRUE,
                    div(
                        class = " d-flex justify-content-center pb-5",
                        actionButton(
                            inputId = "register_now_1",
                            label = "Register Now",
                            class = "mt-5 fw-bold",
                            width = "230px"
                        )
                    )
                )
            )
        )
    ),
    div(
        class = "position-absolute bottom-0 end-0",
        argonImage(
            src = "inst/images/child_4.png",
            floating = TRUE,
            width = "500px"
        )
    ),
    argonSection(
        status = "default",
        class = "pt-5",
        div(
            id = "footer_section",
            div(
                size = "lg",
                status = "default",
                fluidRow(
                    class = "align-items-center",
                    column(
                        width = 6,
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
                    class = "bg-white text-white"
                ),
                fluidRow(
                    class = "align-items-center",
                    column(
                        width = 8,
                        p(
                            display = 1,
                            "Copyright © 2024"
                        ) %>%
                            argonTextColor(
                                color = "white"
                            )
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
)
