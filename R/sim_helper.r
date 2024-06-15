#'
cenPoint <- function(x, lower_quant, upper_quant) {

  if(length(lower_quant)==1 & length(upper_quant)==1) {

    x <- as.matrix(x)

    cen.point <- c(quantile(x, lower_quant), quantile(x, upper_quant))
    cen.point_bi <- vector("list",ncol(x))
    lapply(cen.point_bi, function(x) x <- cen.point)
  } else {

    x <- as.matrix(x)

    cen.point_bi <- lapply(1:ncol(x), function(i) {
      c(quantile(x[,i], lower_quant[i]), quantile(x[,i], upper_quant[i]))
    })
    cen.point_bi
  }
}

#'
cenData <- function(x, cen_point) {

  if(length(cen_point) == 1) {

    x[x[ , 1] <= cen_point[[1]][1] , 1] <- cen_point[[1]][1]
    x[x[ , 1] >= cen_point[[1]][2] , 1] <- cen_point[[1]][2]

    censored_x <- x
  } else {

    censored_x <- sapply(1:ncol(x), function(ii) {

      x[x[ , ii] <= cen_point[[ii]][1] , ii] <- cen_point[[ii]][1]
      x[x[ , ii] >= cen_point[[ii]][2] , ii] <- cen_point[[ii]][2]

      x[, ii]
    })
  }

  censored_x
}
