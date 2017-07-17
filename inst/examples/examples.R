#devtools::install_github("timelyportfolio/d3hierR")

library(d3r)
library(treemap)
library(d3hierR)

rhd <- random.hierarchical.data()

rhd_nest <- d3_nest(
  rhd,
  value_cols = "x"
)

tree(
  rhd_nest,
  sizeField = "x",
  paddingOuter = 10
)

tree(
  rhd_nest,
  sizeField = "x",
  paddingOuter = 20,
  tile = htmlwidgets::JS('d3.treemapBinary')
)
