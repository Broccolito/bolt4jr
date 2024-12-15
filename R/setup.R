.onLoad = function(libname, pkgname) {
  if(!requireNamespace("reticulate", quietly = TRUE)){
    stop("The 'reticulate' package is required but not installed.", call. = FALSE)
  }

  envname = "bolt4jr"
  conda_path = reticulate::conda_binary("auto")

  if(is.null(conda_path)){
    warning("No conda binary found. Please install Miniconda or Anaconda.", call. = FALSE)
    return(invisible(NULL))
  }

  envs = reticulate::conda_list()
  env_exists = any(envs$name == envname)

  if(!env_exists){
    reticulate::conda_create(envname = envname, packages = c("python=3.9"))
    reticulate::conda_install(envname = envname, packages = "neo4j", pip = TRUE)
  }

  reticulate::use_condaenv(envname, required = TRUE)
}
