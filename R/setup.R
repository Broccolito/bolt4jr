.onLoad = function(libname, pkgname) {
  if (!requireNamespace("reticulate", quietly = TRUE)) {
    stop("The 'reticulate' package is required but not installed.", call. = FALSE)
  }

  envname = "bolt4jr"

  conda_path = tryCatch({
    reticulate::conda_binary("auto")
  }, error = function(e) NULL)

  if (is.null(conda_path)) {
    message("No Conda binary found. Installing Miniconda...")
    reticulate::install_miniconda()
    conda_path = reticulate::conda_binary("auto")
  }

  envs = reticulate::conda_list()
  env_exists = any(envs$name == envname)

  if (!env_exists) {
    message(paste("Creating Conda environment:", envname))
    reticulate::conda_create(envname = envname, packages = c("python=3.9"))
    message(paste("Installing 'neo4j' in environment:", envname))
    reticulate::conda_install(envname = envname, packages = "neo4j", pip = TRUE)
  }

  reticulate::use_condaenv(envname, required = TRUE)
}
