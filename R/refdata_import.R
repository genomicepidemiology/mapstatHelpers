#' Import a refdata file
#'
#' @param path Path to refdata file
#'
#' @return A data frame containing the refdata information.
#' @export
#'
#' @examples
read_refdata <- function(path) {
  refdata_header <- unlist(strsplit(sub("# ", "", readLines(con = path, n = 2)[2]), "\t"))

  readr::read_delim(path,
                    delim = "\t",
                    col_names = refdata_header,
                    comment = "#",
                    trim_ws = TRUE)
}
