#' Clean up an R session conservatively
#'
#' Performs common end-of-script cleanup tasks: closes graphics devices,
#' stops parallel clusters referenced in the global environment, closes open
#' connections, disconnects lingering DBI connections, deletes files in the
#' session temporary directory, optionally unloads non-base namespaces, removes
#' objects from the global environment, and triggers garbage collection.
#'
#' @param remove_objects Logical. Remove objects from the global environment. Default TRUE.
#' @param run_gc Logical. Run [base::gc()] at the end and return its summary invisibly. Default TRUE.
#' @param unload_packages Logical. Unload non-base namespaces. Default FALSE.
#' @param remove_tempfiles Logical. Delete files under [base::tempdir()]. Default TRUE.
#' @param verbose Logical. Emit progress messages. Default TRUE.
#'
#' @return Invisibly returns the result of [base::gc()] if run, otherwise `NULL`.
#' @examples
#' \dontrun{
#'   # Register for automatic cleanup on exit
#'   on.exit(clean_session(), add = TRUE)
#'   # ... your analysis ...
#'   clean_session()
#' }
#' @export
clean_session <- function(
  remove_objects   = TRUE,
  run_gc           = TRUE,
  unload_packages  = FALSE,
  remove_tempfiles = TRUE,
  verbose          = TRUE
) {
  msg <- function(...) if (isTRUE(verbose)) message(sprintf(...))

  # 1) Close graphics devices
  try(graphics.off(), silent = TRUE)

  # 2) Stop parallel clusters if they are still referenced in .GlobalEnv
  try({
    objs <- mget(ls(envir = .GlobalEnv), envir = .GlobalEnv, inherits = FALSE)
    cl   <- Filter(function(x) inherits(x, "cluster"), objs)
    if (length(cl)) {
      lapply(cl, function(c) try(parallel::stopCluster(c), silent = TRUE))
      msg("Stopped %d parallel cluster(s).", length(cl))
    }
  }, silent = TRUE)

  # 3) Close all open connections (files, sockets, etc.)
  try(closeAllConnections(), silent = TRUE)

  # 4) Disconnect DBI connections that remain in .GlobalEnv
  try({
    objs <- mget(ls(envir = .GlobalEnv), envir = .GlobalEnv, inherits = FALSE)
    con  <- Filter(function(x) inherits(x, "DBIConnection"), objs)
    if (length(con)) {
      lapply(con, function(c) try(DBI::dbDisconnect(c), silent = TRUE))
      msg("Disconnected %d DBI connection(s).", length(con))
    }
  }, silent = TRUE)

  # 5) Remove temporary files created in this R session
  if (isTRUE(remove_tempfiles)) {
    td <- tempdir()
    tf <- list.files(td, all.files = TRUE, full.names = TRUE, recursive = TRUE, no.. = TRUE)
    if (length(tf)) {
      try(unlink(tf, recursive = TRUE, force = TRUE), silent = TRUE)
      msg("Removed %d temporary file(s).", length(tf))
    }
  }

  # 6) Optionally unload non-base namespaces
  if (isTRUE(unload_packages)) {
    base_ns <- c("base","compiler","datasets","graphics","grDevices","grid",
                 "methods","parallel","splines","stats","stats4","tcltk","tools","utils")
    to_unload <- setdiff(loadedNamespaces(), base_ns)
    for (ns in rev(to_unload)) {
      try(unloadNamespace(ns), silent = TRUE)
    }
    if (length(to_unload)) msg("Unloaded %d namespace(s).", length(to_unload))
  }

  # 7) Remove objects from the global environment
  if (isTRUE(remove_objects)) {
    rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)
  }

  # 8) Trigger garbage collection and return a summary invisibly
  if (isTRUE(run_gc)) {
    gc_out <- gc()
    if (isTRUE(verbose)) print(gc_out)
    invisible(gc_out)
  } else {
    invisible(NULL)
  }
}
