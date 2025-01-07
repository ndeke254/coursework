#' Convert PDF to image
#' @param pdf_path A character string representing the PDF path
#' @param file_name A character string representing the file name
#' @param output_dir A character string representing the output directory
#' @examples
#' \dontrun{
#' # Example of converting PDF to image (commented out due to missing file)
#' # pdf_to_image(pdf_path = "English_Grade6.pdf", file_name = "English.pdf", output_dir = "images")
#' }
#'
#' @import magick
#' @export
pdf_to_image <- function(pdf_path, file_name, output_dir = "www/images") {
  pdf <- magick::image_read_pdf(pdf_path)
  image_paths <- vector("list", length(pdf))
  for (i in seq_along(pdf)) {
    image_path <- file.path(output_dir, paste0(tools::file_path_sans_ext(file_name), "_page_", 1, ".png"))
    magick::image_write(pdf[1], image_path)
    image_paths[[1]] <- image_path
  }
  return(image_paths)
}
