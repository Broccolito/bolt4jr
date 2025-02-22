#' Set up the Conda environment for bolt4jr
#'
#' This function initializes the Conda environment required for the `bolt4jr` package.
#' If no Conda binary is found, it installs Miniconda. If the required Conda environment
#' (`bolt4jr`) is not found, it creates the environment and installs the necessary dependencies.
#'
#' @details
#' The function ensures that:
#' - A Conda binary is available.
#' - A Conda environment named `bolt4jr` exists.
#' - The `neo4j` Python package is installed in the `bolt4jr` environment.
#'
#' Call this function manually before using any functionality that relies on Python.
#'
#' @return No return value, called for side effects.
#' @export
setup_bolt4jr = function(){
  if (!requireNamespace("reticulate", quietly = TRUE)) {
    stop("The 'reticulate' package is required but not installed.", call. = FALSE)
  }

  envname = "bolt4jr"

  conda_path = tryCatch({
    reticulate::conda_binary("auto")
  }, error = function(e) NULL)

  if (is.null(conda_path)){
    message("No Conda binary found. Installing Miniconda...")
    reticulate::install_miniconda()
    conda_path = reticulate::conda_binary("auto")
  }

  envs = reticulate::conda_list()
  env_exists = any(envs$name == envname)

  if (!env_exists){
    message(paste("Creating Conda environment:", envname))
    reticulate::conda_create(envname = envname, packages = c("python=3.9"))
    message(paste("Installing 'neo4j' in environment:", envname))
    reticulate::conda_install(envname = envname, packages = "neo4j", pip = TRUE)
  }

  reticulate::use_condaenv(envname, required = TRUE)
  message("Conda environment setup is complete and ready to use.")
}

