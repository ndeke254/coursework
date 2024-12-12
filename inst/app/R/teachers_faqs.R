teachers_faqs <- div(
  id = "teachers_faqs_page",
  class = "container mt-5 pt-5 px-3 bg-gray-light rounded pb-3 lead",
  tags$h4("TERMS OF PARTNERSHIP",
    class = "text-center text-bold pb-2 text-body-1"
  ),
  p(
    tags$span("Dear"),
    tags$span("Teacher, ", class = "text-bold"),
    tags$span(" Welcome to "),
    tags$span("CANDIDATE™", class = "text-bold")
  ),

  # First FAQ Panel: Partnership Info
  p(
    "We want to partner with you to develop quick study content for your students.",
    class = "mb-4"
  ),
  p(
    tags$span("How does it work?"),
    class = "text-bold"
  ),
  tags$ol(
    tags$li("Pick a subject e.g., mathematics."),
    tags$li("Select a topic you feel needs additional attention e.g., Decimals and percentages."),
    tags$li("Clearly divide the topic into the main concepts."),
    tags$li(
      "Provide brief definitions/explanations that accompany each concept.",
      tags$span("[You are encouraged to use diagrams and illustrations.]",
        class = "text-bold"
      )
    ),
    tags$li("Add examples."),
    tags$li("Scan using your phone and upload on the website, send via email or WhatsApp. If the work is not handwritten, you can save the file and share too."),
    tags$li("You are done.")
  ),

  # Accordion component for FAQ
  bs4Dash::accordion(
    id = "faq_accordion",

    # Second FAQ Panel: Next Steps
    bs4Dash::accordionItem(
      title = "What happens next?",
      class = "bg-secondary",
      collapsed = TRUE,
      tags$div(
        "Our graphic designer will retrieve your uploaded content, create a well-formatted digital version that is uploaded into CANDIDATE™."
      )
    ),

    # Third FAQ Panel: After Upload
    bs4Dash::accordionItem(
      title = "Then?",
      class = "bg-secondary",
      collapsed = TRUE,
      tags$div(
        "Then parents and students are alerted via email that new content has been availed on the portal. If they have already fully subscribed, the content is immediately viewable along with all other content previously uploaded for their grade."
      )
    ),

    # Fourth FAQ Panel: Revenue Share
    bs4Dash::accordionItem(
      title = "How about revenue share?",
      class = "bg-secondary",
      collapsed = TRUE,
      tags$div(
        tags$p("Students pay a termly fixed fee of Ksh. 1500 to access all the content for their grade. The teachers' share is Ksh. 1000, which is divided proportionally among all the teachers of a specific grade; according to a % of engagement calculated as the intersection between their amount of content and number of views."),
        tags$p("This means that, higher content with less views or engagement from students will result to lower earnings. The vice versa is also true. Lower content but with greater traffic will have higher earnings. "),
        tags$ul(
          tags$li("For Example: Grade 6 has 40 students who’ve paid the Ksh. 1500 for the term. The teachers' share is Ksh. 1000"),
          tags$li("Calculations: Ksh. 1000 * 40 = Ksh. 40,000."),
          tags$li("Ksh. 40,000 will be shared among all the teachers who have provided content for grade 6."),
          tags$li("If Teacher X has a % enagement of 50%, they will receive Ksh. 20, 000.")
        )
      )
    ),

    # Fifth FAQ Panel: Money Transfer
    bs4Dash::accordionItem(
      title = "How is the money sent?",
      class = "bg-secondary",
      collapsed = TRUE,
      tags$div(
        "Every 1st day of the month, all monies due to teachers are sent via MPESA."
      )
    )
  ),
  br(),
  tags$p(
    "If you have any questions about our terms of engagement, please contact us at ",
    tags$a(href = "mailto:operational.admin@quickstudy.co.ke", "operational.admin@quickstudy.co.ke")
  ),
  actionButton(
    inputId = "register_teacher",
    label = "Register now",
    class = "text-bold",
    width = "230px"
  )
)
