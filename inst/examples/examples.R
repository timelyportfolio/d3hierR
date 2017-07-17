#devtools::install_github("timelyportfolio/d3hierR")

library(d3r)
library(treemap)
library(d3hierR)

rhd <- random.hierarchical.data()
# make up a fake column for coloring
rhd$spread <- runif(nrow(rhd), -5, 10)

rhd_nest <- d3_nest(
  rhd,
  value_cols = c("x", "spread")
)

# defaults
tree(rhd_nest, sizeField="x")

# clip text
tree(rhd_nest, sizeField="x", clipText=TRUE)

# add paddingOuter
tree(rhd_nest, sizeField="x", paddingOuter=20, clipText=TRUE)

tree(
  rhd_nest,
  sizeField = "x",
  paddingOuter = 10,
  styleText = list("font-size" = "70%")
)

tr <- tree(
  rhd_nest,
  sizeField = "x",
  valueField = "spread",
  paddingOuter = 20,
  clipText = TRUE
)

# use tasks to color by spread
#   for now just do leaf level
#   but can easily accommodate all levels
tr$x$tasks = list(
  htmlwidgets::JS(
"
function() {
  var el = d3.select(this.el);
  var cells = el.selectAll('g.cell rect');
  var valueField = this.x.valueField;
  if(!valueField) {
    return
  }

  // first get min and max
  var extent = d3.extent(cells.data(), function(d) {
    return d.data[valueField];
  });

  var color = d3.scaleLinear()
    .range(['red','white','blue'])
    .domain([extent[0],0,extent[1]])
    .interpolate(d3.interpolateLab);

  cells
    .style('fill', function(d) {
      // just the leaves
      if (d.height === 0) {
        return color(d.data[valueField]);
      }
    })
}
"
  )
)

tr

tree(
  rhd_nest,
  sizeField = "x",
  paddingOuter = 20,
  tile = htmlwidgets::JS('d3.treemapBinary'),
  clipText = TRUE
)
