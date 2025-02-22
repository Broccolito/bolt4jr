#' Connect to Neo4j and Run a Simple Query
#'
#' This function demonstrates connecting to a Neo4j database via the Python neo4j driver
#' and using pandas to manipulate the returned data.
#'
#' @param uri Neo4j URI, e.g., "bolt://localhost:7687"
#' @param user Username for Neo4j
#' @param password Password for Neo4j
#' @param query A Cypher query to execute, e.g. "MATCH (n) RETURN n LIMIT 5"
#'
#' @return A data.frame containing the query results.
#' @export
run_query = function(uri, user, password, query){
  py_neo4j = reticulate::import("neo4j", convert = FALSE)
  driver = py_neo4j$GraphDatabase$driver(uri, auth = py_neo4j$basic_auth(user, password))
  session = driver$session()
  query_result = session$run(query)
  query_result = reticulate::py_to_r(query_result$data())
  return(query_result)
}
