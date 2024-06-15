# for(i in fs::dir_ls("R")){ source(i)}

library(tidyverse)
library(clavaan)
library(lavaan)

unc.data <- lavaan::simulateData('
                     I =~ 1*y1 + 1*y2 + 1*y3 + 1*y4 + 1*y5
                     S =~ 0*y1 + 1*y2 + 2*y3 + 3*y4 + 4*y5

                     I ~ 3*1
                     S ~ 0.5*1

                     I ~~ 1*I + 0.2*S
                     S ~~ 0.5*S
                     ', model.type = 'growth',
                     sample.nobs = 500)


censored_prop <- c(left = 0.2, right = 0.8)

cen_points <- clavaan:::cenPoint(x = unc.data,
                       lower_quant = censored_prop[1],
                       upper_quant = censored_prop[2])


cen.data <- clavaan:::cenData(unc.data, cen_points) %>%
  data.frame() %>%
  set_names(names(unc.data))

model =
  'I =~ 1*y1 + 1*y2 + 1*y3 + 1*y4 + 1*y5
   S =~ 0*y1 + 1*y2 + 2*y3 + 3*y4 + 4*y5

  I ~ 1
  S ~ 1

  I ~~ I + S
  S ~~ S'

cgrowth(model,
  data =cen.data,
  bounds = cen_points,
  model.type = 'growth') %>%
  summary()

lavaan::growth(model,
        data =cen.data) %>%
  summary()

lavaan::growth(model,
       data = unc.data) %>%
  summary()

