#' Batch Query and Save Data from Neo4j
#'
#' This function performs batch queries to a Neo4j database and appends the results to a TSV file.
#'
#' @param uri A string specifying the URI for the Neo4j database connection.
#' @param user A string specifying the username for the Neo4j database.
#' @param password A string specifying the password for the Neo4j database.
#' @param query A string containing the Cypher query to execute. The query should not include `SKIP` or `LIMIT`, as these are appended for batching.
#' @param field_names A character vector specifying the column names to use for the resulting data.
#' @param filename A string specifying the name of the TSV file to save the results. If NULL, a temporary file will be used.
#' @param batch_size An integer specifying the number of records to fetch per batch. Default is 1000.
#'
#' @return No return value, called for side effects.
#' @export
#'
#' @examples
#' \dontrun{
#' run_batch_query(
#'   uri = "bolt://localhost:7687",
#'   user = "<Username for Neo4j>",
#'   password = "<Password for Neo4j>",
#'   query = "MATCH (n) RETURN n LIMIT 10",
#'   field_names = c("id", "name"),
#'   filename = NULL,  # Writes to a temp file by default
#'   batch_size = 1000
#' )
#' }
run_batch_query = function(uri, user, password, query, field_names, filename = NULL, batch_size = 1000) {
  if (is.null(filename)) {
    filename = file.path(tempdir(), "query_results.tsv")
  }

  empty_data = as.data.frame(matrix(character(), ncol = length(field_names)))
  names(empty_data) = field_names
  data.table::fwrite(empty_data, filename, sep = "\t", quote = FALSE)
  skip = 0
  limit = batch_size
  repeat{
    message(glue::glue("Fetching batch starting at {skip}"))
    updated_query = paste0(query, "\n", glue::glue("SKIP {format(skip, scientific = FALSE)} LIMIT {format(limit, scientific = FALSE)}"))
    network_data_snippet = run_query(uri = uri, user = user, password = password, query = updated_query)
    network_data_snippet = convert_df(network_data_snippet, field_names = field_names)
    if (nrow(network_data_snippet) == 0) break
    data.table::fwrite(network_data_snippet, filename, sep = "\t", quote = FALSE, append = TRUE)
    skip = skip + batch_size
  }

  message(glue::glue("Extraction finished. Results saved to: {filename}"))

}
