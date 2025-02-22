#' Convert a Query Result into a Data Frame
#'
#' This function takes a query result object and transforms it into a data frame
#' with specified field names. For each entry in the query result, it attempts
#' to extract values corresponding to the given field names. If a particular field
#' does not exist in the entry, it is replaced with \code{NA}.
#'
#' @param query_result A list (or similar structure) representing the query result,
#'   typically containing entries from which fields can be extracted.
#' @param field_names A character vector of field names to be extracted from each
#'   entry in \code{query_result}. Defaults to \code{c("node_id", "n_identifier", "n.name", "n.source")}.
#'
#' @return A data frame with one row per entry in \code{query_result}, and columns
#'   corresponding to the specified \code{field_names}. Missing fields are filled with \code{NA}.
#'
#' @examples
#' \donttest{
#' # Suppose query_result is a list of named lists:
#' query_result = list(
#'   list(node_id = 1, n = list(identifier = 1, name = "some node", source = "internet")),
#'   list(node_id = 2, n = list(identifier = 2, name = "some other node", source = "library"))
#' )
#'
#' query_result_df = convert_df(
#'   query_result,
#'   field_names = c("node_id", "n.identifier", "n.name", "n.source")
#' )
#' }
#'
#' @export
convert_df = function(query_result,
                      field_names = c("node_id","n.identifier",
                                      "n.name", "n.source")){
  converted_df = purrr::map(query_result, function(x){
    x_vec = unlist(x)
    purrr::map(as.list(field_names), function(fn){
      field_value = NULL
      try({
        field_value = x_vec[[fn]]
      }, silent = TRUE)
      field_value = ifelse(is.null(field_value), NA, field_value)
      return(field_value)
    }) |>
      unlist()
  }) |>
    purrr::reduce(rbind)

  converted_df = as.data.frame(converted_df)
  names(converted_df) = field_names
  rownames(converted_df) = NULL
  return(converted_df)
}
