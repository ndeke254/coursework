#' Process Uploaded Photos
#'
#' This function processes a list of uploaded photos by copying them to a specified
#' destination directory and renaming them with a given base ID and a numeric suffix.
#'
#' @param photos A character vector of file paths to the uploaded photos.
#' @param dest_dir A character string specifying the destination directory where the
#'                  photos will be copied.
#' @param base_id A character string used as the base for renaming the photos (e.g., "REQ-001").
#' @return A character vector of new file paths after renaming and copying.
#' @import fs
#' @export
process_uploaded_photos <- function(photos, dest_dir, base_id) {
  # Ensure the destination directory exists
  fs::dir_create(dest_dir)

  # Initialize a character vector to store the new file paths
  new_file_paths <- character(length(photos))

  # Process each photo
  for (i in seq_along(photos)) {
    # Generate the new file name with the base_id and suffix
    new_file_name <- paste0(base_id, "-", i, ".", fs::path_ext(photos[i]))

    # Define the destination path
    dest_path <- fs::path(dest_dir, new_file_name)

    # Copy the file to the destination directory
    fs::file_copy(photos[i], dest_path, overwrite = TRUE)

    # Store the new file path
    new_file_paths[i] <- dest_path
  }

  return(new_file_paths)
}
