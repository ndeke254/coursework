#' Is app running in production mode?
#'
#' This function checks the `.Renviron` file for the variable 'in_prod'.
#' If `Sys.getenv("in_prod")` evaluates to "TRUE" or an empty string,
#' this function returns `TRUE`.
#' Otherwise, it returns `FALSE`.
#'
#' @seealso [in_development_mode()]
#' @return A length 1 logical vector. `TRUE` if app is in production.
#'  `FALSE` otherwise.
#' @export
in_production_mode <- \() {
  identical(Sys.getenv("in_prod"), "") ||
    identical(Sys.getenv("in_prod"), "TRUE")
}

#' Is app running in development mode?
#'
#' Another way to put it is: Is the app running locally?
#'
#' @seealso [in_production_mode()]
#' @return A length 1 logical vector. `TRUE` if app is in dev mode.
#'  `FALSE` otherwise.
#' @export
in_development_mode <- \() {
  Negate(in_production_mode)()
}
