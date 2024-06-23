# Helper function to convert PDF page to image
pdf_to_image <- function(pdf_path, page = 1, output_dir = "images") {
  img_path <- file.path(output_dir, paste0(basename(pdf_path), "_page", page, ".png"))
  pdf_image <- image_read_pdf(pdf_path, pages = page)
  image_write(pdf_image, img_path)
  return(img_path)
}
