# .onAttach <- function(libname, pkgname) {
#   version <- read.dcf(file=system.file("DESCRIPTION", package=pkgname),
#                       fields="Version")
#   packageStartupMessage("This is ",paste(pkgname, version))
#   packageStartupMessage('Censored SEM via lavaan')
# }


val_inputs <- function(bounds) {

  if(is.null(names(bounds))) {
    message("Censored points must be named. For example, list(y1 = c(1, 5), y2 = c(1,5))")
  }

}
