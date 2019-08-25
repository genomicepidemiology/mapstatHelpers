#' Import a mapstat file
#'
#' @param path Path to file
#' @param shorten_sample_id Should the \code{sample_id} variable in the output
#'   be shortened?
#'
#'   If \code{TRUE}, "samplename" is returned instead of the full path
#'   "foo/bar/samplename.mapstat". If\code{FALSE}, the full path is returned.
#'
#' @return
#' @export
#'
#' @examples
read_single_mapstat <- function(path, shorten_sample_id = TRUE) {
  mapstat_header <- unlist(strsplit(sub("# ", "", readLines(con = path, n = 7)[7]), "\t"))

  tmp_df <- readr::read_delim(path,
                              delim = "\t",
                              col_names = mapstat_header,
                              comment = "#",
                              trim_ws = TRUE)

  if(nrow(tmp_df) > 0)
    tmp_df$sample_id <- ifelse(shorten_sample_id,
                        sub(".mapstat", "", basename(path)),
                        path)
  return(tmp_df)
}

#' Import multiple mapstat files
#'
#' @param input Either the name of a directory containing the files to be
#'   imported, or a character vector containing file paths.
#'
#' @param type Specify whether the \code{input} is of type "directory" (default)
#'   or "vector".
#' @param ... Additional arguments to be passed to \code{\link{read_single_mapstat}}.
#'   At the moment, the only such argument is \code{shorten_sample_id}.
#'
#' @return
#' @export
#' @importFrom rlang .data
#'
#' @examples
read_multiple_mapstats <- function(input, type = "directory", ...) {
  input_files <- parse_multi_input(input_to_parse = input, type_to_parse = type)

  out_tmp <- purrr::map(input_files, read_single_mapstat, ...)
  out_df <- dplyr::bind_rows(out_tmp)

  return(dplyr::select(out_df, .data$sample_id, dplyr::everything()))
}
