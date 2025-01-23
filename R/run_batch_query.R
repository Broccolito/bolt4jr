#' Batch Query and Save Data from Neo4j
#'
#' This function performs batch queries to a Neo4j database and appends the results to a TSV file.
#'
#' @param uri A string specifying the URI for the Neo4j database connection.
#' @param user A string specifying the username for the Neo4j database.
#' @param password A string specifying the password for the Neo4j database.
#' @param query A string containing the Cypher query to execute. The query should not include `SKIP` or `LIMIT`, as these are appended for batching.
#' @param field_names A character vector specifying the column names to use for the resulting data.
#' @param filename A string specifying the name of the TSV file to save the results.
#' @param batch_size An integer specifying the number of records to fetch per batch. Default is 1000.
#'
#' @return The function saves the query results to a TSV file incrementally and does not return any object.
#' @export
#'
#' @examples
#' \donttest{
#' run_batch_query(
#'   uri = "bolt://localhost:7687",
#'   user = "<Username for Neo4j>",
#'   password = "<Password for Neo4j>",
#'   query = "
#'   MATCH (n)-[r]-(m)
#'   WHERE type(r) IN ['ISA_AiA', 'PARTOF_ApA']
#'   RETURN DISTINCT
#'     elementId(r) AS edge_id,
#'     elementId(startNode(r)) AS start_node_id,
#'     elementId(endNode(r)) AS end_node_id,
#'     r",
#'   field_names = c("edge_id", "start_node_id", "end_node_id"),
#'   filename = "edges.tsv",
#'   batch_size = 1000
#' )
#' }

run_batch_query = function(uri, user, password, query, field_names, filename, batch_size = 1000) {
  empty_data = as.data.frame(matrix(character(), ncol = length(field_names)))
  names(empty_data) = field_names
  data.table::fwrite(empty_data, filename, sep = "\t", quote = FALSE)
  skip = 0
  limit = batch_size
  repeat{
    message(glue::glue("Fetching batch starting at {skip}"))
    updated_query = paste0(query, "\n", glue::glue("SKIP {skip} LIMIT {limit}"))
    network_data_snippet = run_query(uri = uri, user = user, password = password, query = updated_query)
    network_data_snippet = convert_df(network_data_snippet, field_names = field_names)
    if (nrow(network_data_snippet) == 0) break
    data.table::fwrite(network_data_snippet, filename, sep = "\t", quote = FALSE, append = TRUE)
    skip = skip + batch_size
  }

  message("Extraction finished.")
}
