#' Create a landing page card
#' 
#' @param class Card class
#' @param data_aos Data AOS. Refer to AOS JS
#' @param data_aos_delay Data AOS delay
#' @param icon_class Icon class
#' @param title Card title
#' @param description Card description
create_landing_page_card <- function(
    class = "col-md-6 col-lg-3 d-flex align-items-stretch mb-5 mb-lg-0",
    data_aos = "zoom-in",
    data_aos_delay = "200",
    icon_class = "bi bi-stack",
    title = "Runoff Triangle Generation",
    description = "Generate runoff triangles super fast and efficiently!"
  ) {
  card <- tags$div(
    class = class,
    `data-aos` = data_aos,
    `data-aos-delay` = data_aos_delay,
    tags$div(
      class = "icon-box",
      tags$div(
        class = "icon",
        tags$i(
          class = icon_class
        )
      ),
      tags$h4(
        class = "title",
        tags$p(title)
      ),
      tags$p(
        class = "description",
        description
      )
    )
  )
  
  tagList(card)
}
