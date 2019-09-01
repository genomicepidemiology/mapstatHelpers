#' Import the metadata of a mapstat file
#'
#' @inheritParams read_single_mapstat
#'
#' @return A list containing the six metadata fields parsed from the 'mapstat' file.
#' @export
get_single_metadata <- function(path, shorten_sample_id = TRUE) {
  sample_id <- ifelse(shorten_sample_id,
                      sub(".mapstat", "", basename(path)),
                      path)
  tmp_res <- as.list(sub(pattern = "##\\s\\w+\\t",
                         replacement = "",
                         x = c(sample_id, readLines(con = path, n = 6))))
  names(tmp_res) <- c("sample_id", "method", "method_version", "db_version",
                      "total_fragments", "date", "command")
  tmp_res[[5]] <- as.integer(tmp_res[[5]])
  tmp_res[[6]] <- as.Date.character(tmp_res[[6]])
  return(tmp_res)
}

#' Import the metadata from many mapstat files
#'
#' @param ... Additional arguments to be passed to \code{\link{get_single_metadata}}.
#'   At the moment, the only such argument is \code{shorten_sample_id}.
#' @inheritParams read_multiple_mapstats
#'
#' @return A data frame containing the metadata of the provided mapstat files.
#'   A quick summary of each column is printed to the console.
#' @export
get_multiple_metadata <- function(input, type = "directory", ...) {
  input_files <- parse_multi_input(input_to_parse = input, type_to_parse = type)

  tmp_list <- purrr::map(input_files, get_single_metadata, ...)

  mapstat_metadata <- dplyr::bind_rows(tmp_list)

  check_metadata(mapstat_metadata)

  return(mapstat_metadata)
}

#' Check mapstat metadata
#'
#' @param meta_df Metadata data frame that should be checked. It is expected that
#'   you imported this one with \code{\link{get_multiple_metadata}}.
#'
#' @return Nothing is returned. Only prints a summary the console
#' @export
check_metadata <- function(meta_df) {
  cat("--------- Mapstat metadata summary ---------\n")

  cat(paste0("No. of mapstat files:\t", nrow(meta_df), "\n"))
  cat(paste0("Date of mapping:\t", ifelse(length(unique(meta_df$date)) == 1,
                                          as.character(unique(meta_df$date)),
                                          paste(range(meta_df$date), collapse = " to ")), "\n"))
  cat(paste0("Mapping method(s):\t", paste(unique(meta_df$method), collapse = ", "), "\n"))
  cat(paste0("Method version(s):\t", paste(unique(meta_df$method_version), collapse = ", "), "\n"))
  cat(paste0("Database version(s):\t", paste(unique(meta_df$db_version), collapse = ", "), "\n"))

  column_conflicts <- apply(meta_df[, 2:4], 2, function(x) length(unique(x)) > 1)
  if(any(column_conflicts))
    message("\nCareful! The following fields have more than one entry:\n",
            paste(names(which(column_conflicts)), collapse = ", "), "\n\n",
            "Consider remapping so that all samples are mapped in the same manner.")
}
