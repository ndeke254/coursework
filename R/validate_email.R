#' 
#' validate if an input is an email
#' check whether it ends with `@gmail.com`
#' 
#' @param email. An email address
#' @return logical. TRUE or FALSE
#' @example 
#' validate("john@gmail.com")
#' TRUE
#' 
#'@export 
#' 
validate_email <- function(email) {
  # Define the pattern for a valid email ending with @gmail.com
  pattern <- "^\\w+([-+.']\\w+)*@gmail\\.com$"
  
  # Use grepl to check if the email matches the pattern
  is_valid <- grepl(pattern, email, ignore.case = TRUE)
  
  return(is_valid)
}