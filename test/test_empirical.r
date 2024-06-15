library(lavaan)

model = "
yI =~ 1*y1 + 1*y2 + 1*y3 + 1*y4
yS =~ 0*y1 + 1*y2 + 2*y3 + 3*y4

# xI =~ 1*x1 + 1*x2 + 1*x3 + 1*x4
# xS =~ 0*x1 + 1*x2 + 2*x3 + 3*x4

# I ~ x1 + gen
# S ~ x1 + gen
#
# x1 ~ 1
# gen ~ 1
"



cfit <- clavaan::cgrowth(model = model, data = dc,
                         bounds =
                           list(y4 = c(0, 100), y2 = c(0, 100), y3 = c(0, 100), y1 = c(0, 100))
)

cfit <- clavaan::cgrowth(model = model, data = dc,
                         bounds =
                           list(c(0, 100), c(0, 100),c(0, 100),c(0, 100),
                                c(0,10),c(0,10),c(0,10),c(0,10),
                                c(-Inf,Inf))
                         )
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



fit <- lavaan::growth(model = model, dc, missing = "fiml")

summary(cfit, fit.measures = T, standardized = T)
summary(fit, fit.measures = T, standardized = T)

