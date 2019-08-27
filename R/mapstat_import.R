#' Import a mapstat file
#'
#' @param path Path to file
#' @param shorten_sample_id Should the \code{sample_id} variable in the output
#'   be shortened?
#'
#'   If \code{TRUE}, "samplename" is returned instead of the full path
#'   "foo/bar/samplename.mapstat". If\code{FALSE}, the full path is returned.
#' @param engine Which function should be used to read in the files?
#'
#'   The default, \code{"readr"}, uses the \code{read_delim()} function from the \code{readr}
#'   package. You can also choose \code{"fread"}, which will use \code{fread()}
#'   from the \code{data.table} package.
#'
#'   \code{"readr"} is a bit slower, but throws more useful warnings. You can cut
#'   the reading time by about 30 to 40 percent with \code{"fread"}.
#'
#' @return A data frame containing information from the imported mapstat file.
#'   The (by default shortened) filename is added in a column called \code{sample_id}.
#' @export
read_single_mapstat <- function(path, shorten_sample_id = TRUE, engine = "readr") {
  mapstat_header <- unlist(strsplit(sub("# ", "", readLines(con = path, n = 7)[7]), "\t"))

  if (engine == "fread")
    tmp_df <- data.table::fread(file = path,
                                sep = "\t",
                                skip = 7,
                                col.names = mapstat_header,
                                # mapScoreSum and bpTotal can be higher than 2^31
                                # columns have to be adressed by number (explicit name won't work)
                                colClasses = list(double = c(4, 7)))
  if (engine == "readr")
    tmp_df <- readr::read_delim(path,
                                delim = "\t",
                                col_names = mapstat_header,
                                skip = 7,
                                trim_ws = TRUE,
                                progress = F,
                                col_types = readr::cols(
                                  refSequence = readr::col_character(),
                                  readCount = readr::col_integer(),
                                  fragmentCount = readr::col_integer(),
                                  mapScoreSum = readr::col_double(),
                                  refCoveredPositions = readr::col_integer(),
                                  refConsensusSum = readr::col_integer(),
                                  bpTotal = readr::col_double(),
                                  depthVariance = readr::col_double(),
                                  nucHighDepthVariance = readr::col_integer(),
                                  depthMax = readr::col_integer(),
                                  snpSum = readr::col_integer(),
                                  insertSum = readr::col_integer(),
                                  deletionSum = readr::col_integer()
                                ))

  if(nrow(tmp_df) > 0)
    tmp_df$sample_id <- ifelse(shorten_sample_id,
                               sub(".mapstat", "", basename(path)),
                               path)
  return(as.data.frame(tmp_df))
}

#' Import multiple mapstat files
#'
#' @param input Either the name of a directory containing the files to be
#'   imported, or a character vector containing file paths.
#'
#' @param type Specify whether the \code{input} is of type "directory" (default)
#'   or "vector".
#' @param ... Additional arguments to be passed to \code{\link{read_single_mapstat}},
#'   auch as \code{shorten_sample_id} and \code{engine}.
#'
#' @return A data frame containing information from all imported mapstat files.
#'   The (by default shortened) filenames are added in a column called \code{sample_id}.
#' @export
#' @importFrom rlang .data
read_multiple_mapstats <- function(input, type = "directory", ...) {
  input_files <- parse_multi_input(input_to_parse = input, type_to_parse = type)

  out_tmp <- purrr::map(input_files, read_single_mapstat, ...)
  out_df <- dplyr::bind_rows(out_tmp)

  return(dplyr::select(out_df, .data$sample_id, dplyr::everything()))
}
