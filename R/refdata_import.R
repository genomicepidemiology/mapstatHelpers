#' Import a refdata file
#'
#' @param path Path to refdata file
#' @inheritParams read_single_mapstat
#' @return A data frame containing the refdata information.
#' @export
read_refdata <- function(path, engine = "readr") {
  refdata_header <- unlist(strsplit(sub("# ", "", readLines(con = path, n = 2)[2]), "\t"))

  if(engine == "fread")
    as.data.frame(data.table::fread(file = path,
                                    sep = "\t",
                                    skip = 2,
                                    col.names = refdata_header))
  if(engine == "readr")
    as.data.frame(readr::read_delim(path,
                                    delim = "\t",
                                    col_names = refdata_header,
                                    # col_types =
                                    #   readr::cols(
                                    #     .default = readr::col_character(),
                                    #     id_len = readr::col_integer(),
                                    #     db_order = readr::col_integer()
                                    #   ),
                                    skip = 2,
                                    trim_ws = TRUE))
}
