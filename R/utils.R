# Switch for parsing different input types:
#   * directory
#   * vector
parse_multi_input <- function(input_to_parse, type_to_parse) {
  if (!is.character(input_to_parse))
    stop('`input` must be a character vector.')

  if (! type_to_parse %in% c("directory", "vector"))
    stop('`type` must be either "directory" (default) or "vector".')

  if(type_to_parse == "directory")
    return(list.files(input_to_parse, pattern = ".mapstat", full.names = T))

  if(type_to_parse == "vector")
    return(input_to_parse)
}
