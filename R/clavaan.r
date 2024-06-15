#' Run growth model with censored data
#'
#' @description
#' `cgrowth()`
#'
#' @param model lavaan model
#' @param data data frame
#' @param bounds a list of ensored points. It should be a list with the names of censored data and upper/lower censored points. For example, list(y1 = c(1, 5), y2 = c(1, 5))
#' @param ...
#'
#'  Additional `lavaan` arguments
#'
#' @returns
#' `cgrowth()` returns `lavaan` class.
#' @export
cgrowth <- function(model = NULL, data = NULL, bounds = NULL, ...) {

  mc <- match.call(expand.dots = TRUE)

  val_inputs(bounds)

  if(!is.null(names(bounds))) {
    nocen_nm <- names(data)[!names(data) %in% names(bounds)]
    nocen_bounds <- lapply(1:length(nocen_nm), function(x) c(-Inf,Inf))
    names(nocen_bounds) <- nocen_nm
    bounds <- append(bounds, nocen_bounds)
    bounds <- bounds[names(data)]
  }

  sample.info <- cMulti(data, bounds)

  colnames(sample.info[[2]]) <- names(data)
  rownames(sample.info[[2]]) <- names(data)

  mc$sample.nobs = nrow(data)
  mc$sample.mean = sample.info[[1]]
  mc$sample.cov = sample.info[[2]]

  mc[['bounds']] <- NULL
  mc[['data']] <- NULL

  dotdotdot <- list(...)
  if (is.null(dotdotdot$estimator)) {
    mc$estimator = "GLS"
  }

  mc[[1L]] <- quote(lavaan::growth)
  eval(mc, parent.frame())
}

#' Run SEM model with censored data
#'
#' @description
#' `csem()`
#'
#' @param model lavaan model
#' @param data data frame
#' @param bounds  a list of ensored points. It should be a list with the names of censored data and upper/lower censored points. For example, list(y1 = c(1, 5), y2 = c(1, 5))
#' @param ...
#'
#'  Additional lavaan arguments
#'
#' @returns
#' `csem()` returns `lavaan` class.
#' @export
csem <- function(model = NULL, data = NULL, bounds = NULL, ...) {

  mc <- match.call(expand.dots = TRUE)

  val_inputs(bounds)

  if(!is.null(names(bounds))) {
    nocen_nm <- names(data)[!names(data) %in% names(bounds)]
    nocen_bounds <- lapply(1:length(nocen_nm), function(x) c(-Inf,Inf))
    names(nocen_bounds) <- nocen_nm
    bounds <- append(bounds, nocen_bounds)
    bounds <- bounds[names(data)]
  }

  sample.info <- cMulti(data, bounds)

  colnames(sample.info[[2]]) <- names(data)
  rownames(sample.info[[2]]) <- names(data)

  mc$sample.nobs = nrow(data)
  mc$sample.mean = sample.info[[1]]
  mc$sample.cov = sample.info[[2]]

  mc[['bounds']] <- NULL
  mc[['data']] <- NULL

  dotdotdot <- list(...)
  if (is.null(dotdotdot$estimator)) {
    mc$estimator = "GLS"
  }

  mc[[1L]] <- quote(lavaan::sem)
  eval(mc, parent.frame())
}

#' Run CFA model with censored data
#'
#' @description
#' `ccfa()`
#'
#' @param model lavaan model
#' @param data data frame
#' @param bounds a list of ensored points. It should be a list with the names of censored data and upper/lower censored points. For example, list(y1 = c(1, 5), y2 = c(1, 5))
#' @param ...
#'
#'  Additional lavaan arguments
#'
#' @returns
#' `ccfa()` returns `lavaan` class.
#' @export
ccfa <- function(model = NULL, data = NULL, bounds = NULL, ...) {

  mc <- match.call(expand.dots = TRUE)

  val_inputs(bounds)

  if(!is.null(names(bounds))) {
    nocen_nm <- names(data)[!names(data) %in% names(bounds)]
    nocen_bounds <- lapply(1:length(nocen_nm), function(x) c(-Inf,Inf))
    names(nocen_bounds) <- nocen_nm
    bounds <- append(bounds, nocen_bounds)
    bounds <- bounds[names(data)]
  }

  sample.info <- cMulti(data, bounds)

  colnames(sample.info[[2]]) <- names(data)
  rownames(sample.info[[2]]) <- names(data)

  mc$sample.nobs = nrow(data)
  mc$sample.mean = sample.info[[1]]
  mc$sample.cov = sample.info[[2]]

  mc[['bounds']] <- NULL
  mc[['data']] <- NULL

  dotdotdot <- list(...)
  if (is.null(dotdotdot$estimator)) {
    mc$estimator = "GLS"
  }

  mc[[1L]] <- quote(lavaan::cfa)
  eval(mc, parent.frame())
}

