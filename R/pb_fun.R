pb_fun <- function(x, fun, ...) {
  if (requireNamespace("pbapply")) {
    pbapply::pblapply(x, fun, ...)
  } else {
    lapply(x, fun, ...)
  }
}
