library(shiny)
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

tr <- tree(
  rhd_nest,
  sizeField = "x",
  valueField = "spread",
  paddingOuter = 14,
  clipText = TRUE,
  styleText = list("font-size" = "70%"),
  tile = htmlwidgets::JS("d3.treemapBinary")
)

# use tasks to color by spread
#   for now just do leaf level
#   but can easily accommodate all levels
tr$x$tasks = list(
  htmlwidgets::JS(
    "
    function() {

    debugger;
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

tr2 <- tr
tr2$x$tasks <- c(
  tr2$x$tasks,
  list(
    htmlwidgets::JS(
"
function() {
  var el = this.el;
debugger
  d3.select(this.el).selectAll('g.cell').each(function(data) {
    new Tooltip(this, {
      placement: 'top',
      container: el,
      title: function() {
        return d3.select(this).datum().data.name
      },
      template: \"<div class='tooltip-popper' role='tooltip'><div class='tooltip-arrow'></div><div class='tooltip-inner'></div></div>\"
    });
  });
}
"
    )
  )
)

ui <- fluidPage(
  tr,
  tr2,
  tags$head(
    tags$script(src="https://unpkg.com/popper.js@1.10.8"),
    tags$script(src="https://unpkg.com/tooltip.js@1.1.4/dist/umd/tooltip.min.js")
  )
)
server <- function(input, output, session) {

}
shinyApp(ui, server)
