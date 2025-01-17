# Bolt4jr

`bolt4jr` is an R package designed to efficiently query, extract, and process large-scale network data from Neo4j databases using the Bolt protocol, with built-in support for batch processing and data frame conversion.

## Overview

`bolt4jr` is an R package that facilitates interaction with Neo4j databases using the Bolt protocol. It allows users to efficiently query nodes and edges in a Neo4j graph database, convert results into data frames, and process large datasets in batches. The package is especially useful for extracting large-scale network data for bioinformatics, computational biology, and other applications.

This README provides a comprehensive guide to installing and using the `bolt4jr` package for extracting network data from Neo4j.

------

## Installation

To install the `bolt4jr` package directly from its GitHub repository, use the `remotes` package:

```R
# Install remotes if not already installed
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# Install bolt4jr from GitHub
remotes::install_github("Broccolito/bolt4jr")
```

------

## Setting Up Environment Variables

To securely store your Neo4j connection details (URI, username, and password), you can use environment variables. This ensures that sensitive information is not hard-coded in your scripts.

1. Open your `.Renviron` file:

   ```R
   usethis::edit_r_environ()
   ```

2. Add the following lines to the file, replacing placeholders with your connection details:

   ```
   NEO4J_URI=bolt://<YOUR_NEO4J_URI>
   NEO4J_USER=<YOUR_USERNAME>
   NEO4J_PASSWORD=<YOUR_PASSWORD>
   ```

3. Save the file and restart your R session to load the environment variables.

4. Access the stored variables in R:

   ```R
   uri = Sys.getenv("NEO4J_URI")
   username = Sys.getenv("NEO4J_USER")
   password = Sys.getenv("NEO4J_PASSWORD")
   ```

5. Set up conda environment

   ```R
   setup_bolt4jr()
   ```

   This function initializes the Conda environment required for the `bolt4jr` package.
   If no Conda binary is found, it installs Miniconda. If the required Conda environment (`bolt4jr`) is not found, it creates the environment and installs the necessary dependencies.

------

## Querying Nodes and Edges from Neo4j

### Querying Nodes

To query nodes from a Neo4j database, use the `run_query` function. Here's an example:

```R
library(bolt4jr)

# Query nodes
nodes = run_query(
  uri = uri,
  user = username,
  password = password,
  query = "
  MATCH (n)-[r]-(m)
  WHERE type(r) IN ['ISA_AiA', 'PARTOF_ApA']
  RETURN DISTINCT elementId(n) AS node_id, n
  LIMIT 1000"
)

# Examine the structure of the result
unlist(nodes[[1]])
```

#### Example Output (Unlisted Structure):

```
$node_id
[1] "4:c77f6410-bc08-43ba-a172-0503ab1c93db:0"
$n.identifier
[1] "UBERON:0003233"
$n.name
[1] "epithelium of shoulder"
$n.mesh_id
[1] ""
$n.source
[1] "Uberon"
```

#### Extract Specific Fields and Convert to a Data Frame:

```R
nodes = convert_df(
  nodes,
  field_names = c("node_id", "n.identifier", "n.name", "n.source")
)

# View the resulting data frame
head(nodes)
```

#### Example Output (Nodes Data Frame):

| node_id                                  | n.identifier   | n.name                           | n.source |
| ---------------------------------------- | -------------- | -------------------------------- | -------- |
| 4:c77f6410-bc08-43ba-a172-0503ab1c93db:0 | UBERON:0003233 | epithelium of shoulder           | Uberon   |
| 4:c77f6410-bc08-43ba-a172-0503ab1c93db:1 | UBERON:2001901 | ceratobranchial 3 element        | Uberon   |
| 4:c77f6410-bc08-43ba-a172-0503ab1c93db:2 | UBERON:0004321 | middle phalanx of manual digit 3 | Uberon   |
| 4:c77f6410-bc08-43ba-a172-0503ab1c93db:3 | UBERON:0002414 | lumbar vertebra                  | Uberon   |
| 4:c77f6410-bc08-43ba-a172-0503ab1c93db:4 | UBERON:2005118 | middle lateral line primordium   | Uberon   |
| 4:c77f6410-bc08-43ba-a172-0503ab1c93db:5 | UBERON:0034769 | lymphomyeloid tissue             | Uberon   |

------

### Querying Edges

Similarly, you can query edges:

```R
# Query edges
edges = run_query(
  uri = uri,
  user = username,
  password = password,
  query = "
  MATCH (n)-[r]-(m)
  WHERE type(r) IN ['ISA_AiA', 'PARTOF_ApA']
  RETURN DISTINCT
    elementId(r) AS edge_id,
    elementId(startNode(r)) AS start_node_id,
    elementId(endNode(r)) AS end_node_id,
    r
  LIMIT 1000"
)

# Examine the structure of the result
unlist(edges[[1]])

# Extract specific fields and convert to a data frame
edges = convert_df(
  edges,
  field_names = c("edge_id", "start_node_id", "end_node_id")
)

# View the resulting data frame
head(edges)
```

#### Example Output (Edges Data Frame):

| edge_id                                   | start_node_id                            | end_node_id                              |
| ----------------------------------------- | ---------------------------------------- | ---------------------------------------- |
| 4:c77f6410-bc08-43ba-a172-0503ab1c93db:10 | 4:c77f6410-bc08-43ba-a172-0503ab1c93db:0 | 4:c77f6410-bc08-43ba-a172-0503ab1c93db:1 |
| 4:c77f6410-bc08-43ba-a172-0503ab1c93db:11 | 4:c77f6410-bc08-43ba-a172-0503ab1c93db:2 | 4:c77f6410-bc08-43ba-a172-0503ab1c93db:3 |

------

## Extracting Large Datasets in Batches

For large networks, you can use the `run_batch_query` function to process data in chunks. This function appends results to a file incrementally, minimizing memory usage.

### Extracting Edges in Batches

```R
run_batch_query(
  uri = uri,
  user = username,
  password = password,
  query = "
  MATCH (n)-[r]-(m)
  WHERE type(r) IN ['ISA_AiA', 'PARTOF_ApA']
  RETURN DISTINCT
    elementId(r) AS edge_id,
    elementId(startNode(r)) AS start_node_id,
    elementId(endNode(r)) AS end_node_id,
    r",
  field_names = c("edge_id", "start_node_id", "end_node_id"),
  filename = "edges.tsv",
  batch_size = 1000
)
```

------

### Extracting Nodes in Batches

```R
run_batch_query(
  uri = uri,
  user = username,
  password = password,
  query = "
  MATCH (n)-[r]-(m)
  WHERE type(r) IN ['ISA_AiA', 'PARTOF_ApA']
  RETURN DISTINCT elementId(n) AS node_id, n",
  field_names = c("node_id", "n.identifier", "n.name", "n.source"),
  filename = "nodes.tsv",
  batch_size = 1000
)
```

------

## Additional Features

### Convert Query Results to Data Frames

The `convert_df` function simplifies converting Neo4j query results into R data frames.

```R
# Convert query results to a data frame
nodes = convert_df(
  nodes,
  field_names = c("node_id", "n.identifier", "n.name", "n.source")
)

# View the data frame
head(nodes)
```

------

## Troubleshooting

- **Connection Issues**: Ensure that your Neo4j database is running and the URI, username, and password are correct.
- **Environment Variables Not Loaded**: Verify that the `.Renviron` file is saved correctly and restart your R session.
- **Large Query Limits**: Use `run_batch_query` for datasets exceeding memory limits.

------

## Contributing

Contributions to `bolt4jr` are welcome! Submit issues or pull requests on the [GitHub repository](https://github.com/Broccolito/bolt4jr). Alternatively, please contact [Wanjun Gu](mailto:wanjun.gu@ucsf.edu) for questions and clarifications.
