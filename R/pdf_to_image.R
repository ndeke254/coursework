#' Convert PDF pages to images
#' 
#' @param pdf_path. A path to the pdf location with the PDF name appended
#' @param file_name. Name of the uploaded PDF with extension
#' @param output_dir. A path to the location to store PDF images
#' @return paths to the converted PDF images
#' @example 
#' pdf_to_image(
#' pdf_path = "www/pdf/English_Grade6.pdf",
#' file_name = "English_Grade6.pdf",
#' output_dir = "www/images"
#' )
#' @export 

pdf_to_image <- function(pdf_path, file_name, output_dir = "www/images") {
      pdf <- image_read_pdf(pdf_path)
    image_paths <- vector("list", length(pdf))
    for (i in seq_along(pdf)) {
      image_path <- file.path(output_dir, paste0(tools::file_path_sans_ext(file_name), "_page_", i, ".png"))
      image_write(pdf[i], image_path)
      image_paths[[i]] <- image_path
    }
}
