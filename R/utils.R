
#' Write a read-only tab-separated-value file
#' @param x a dataframe
#' @param path path to where the file should be saved
#' @return invisibly returns the input `x`
#' @export
write_protected_tsv <- function(x, path) {
  readr::write_tsv(x, path)
  Sys.chmod(path, mode = "0444")
  invisible(x)
}
