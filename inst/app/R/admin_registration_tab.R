label_mandatory <- \(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}
admin_registration_tab <- div(
  h2("Register new school"),
  argonRow(
    center = TRUE,
    argonCard(
      title = "School Registration Form",
      status = "default",
      border_level = 5,
      shadow = TRUE,
      icon = icon("address-card"),
      width = 6,
      tags$head(
        tags$style(HTML("
      #step_1, #step_2 {
      height: 15px; width: 15px; margin: 0 10px;
      background-color: #bbbbbb; border: 0.5px solid; border-radius: 50%;
      display: inline-block; opacity: 0.5; box-shadow: 0px 0px 10px 0px #0000003b;
      }
      #line {
      box-shadow: 0px 0px 10px 0px #0000003b;
      height: 2px; background-color: #bbbbbb; margin: 0 5px; flex-grow: 1; 4
      }
    "))
      ),
      div(
        id = "reg_form",
        p("All fields are required", class = "mt--2") |>
          argonMuted(),
        div(
          class = "align-items-center d-flex m-auto mt-2 w-75",
          span(id = "step_1"),
          span(id = "line"),
          span(id = "step_2")
        ),
        div(
          class = "m-auto pb-3 w-75",
          div(
            class = "d-flex justify-content-between pt-2",
            p("Details"),
            p("Confirm")
          )
        ),
        div(
          id = "tab_1",
          h3("Details", class = "mt--3 mb-3"),
          argonRow(
            argonColumn(
              width = 6,
              shiny::textInput("school_name", label_mandatory("Name:"), "", placeholder = "Eg. Lenga Juu")
            ),
            argonColumn(
              width = 6,
              shinyWidgets::pickerInput(
                inputId = "school_level",
                label = label_mandatory("Level:"),
                options = list(
                  style = "btn-outline-light",
                  title = "Eg. Primary"
                ),
                choices = c("Preparatory", "Primary", "Junior Secondary", "Senior Secondary", "University/College", "Other")
              )
            )
          ),
          argonRow(
            argonColumn(
              width = 6,
              shinyWidgets::pickerInput(
                inputId = "school_type",
                label = label_mandatory("Type:"),
                options = list(
                  style = "btn-outline-light",
                  title = "Eg. Public"
                ),
                choices = c("Public", "Private", "Other")
              )
            ),
            argonColumn(
              width = 6,
              shinyWidgets::pickerInput(
                inputId = "county",
                label = label_mandatory("County:"),
                options = list(
                  title = "Eg. Nairobi",
                  style = "btn-outline-light",
                  size = 5,
                  `live-search` = TRUE,
                  `live-search-placeholder` = "Search county"
                ),
                choices = kenyan_counties,
                autocomplete = TRUE
              )
            )
          )
        ),
        shinyjs::hidden(
          div(
            id = "tab_2",
            argonColumn(
              width = 12,
              h3("Confirm", class = "mt--3 mb-3"),
              p("New school details", class = "mt-3"),
              uiOutput("school_data")
            )
          )
        ),
        div(
          style = "overflow: auto; margin-top: 20px;",
          div(
            id = "tab_buttons",
            class = "d-flex mt-3 justify-content-end",
            shinyjs::hidden(
              shiny::actionButton("prevBtn", "", icon = icon("arrow-left"), class = "px-5")
            ),
            shinyjs::hidden(
              shiny::actionButton("confirmBtn", "", icon = icon("check"), class = "px-5")
            ),
            shiny::actionButton("nextBtn", "", icon = icon("arrow-right"), class = "px-5")
          )
        )
      )
    )
  )
)
