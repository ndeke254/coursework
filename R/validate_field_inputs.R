#' Check existent of a NULL, NA or empty("") field in a form
#' 
#' @param inputs. A list. A list of the fields with their inputId as names
#' 
#' @return  A list of inputId for fields with errors
#' @example 
#' fields <- list(
#' name = input$name,
#' school = input$school,
#' grade = input$grade
#' )
#' validate_inputs(fields)
#' 
#' @export
#' 
  validate_inputs <- function(inputs) {
    invalid_fields <- list()
    for (name in names(inputs)) {
      input <- inputs[[name]]
      if (is.null(input) || input == "" || is.na(input)) {
        invalid_fields <- c(invalid_fields, name)
      }
    }
    return(invalid_fields)
  }