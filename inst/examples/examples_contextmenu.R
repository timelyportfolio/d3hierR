library(shiny)
#devtools::install_github("timelyportfolio/d3hierR")
library(d3r)
library(treemap)
library(d3hierR)
library(htmltools)

rhd <- random.hierarchical.data()
# make up a fake column for coloring
rhd$toxicity <- runif(nrow(rhd), 0, 2)

rhd_nest <- d3_nest(
  rhd,
  value_cols = c("x", "toxicity")
)

tr <- tree(
  rhd_nest,
  sizeField = "x",
  valueField = "toxicity",
  paddingOuter = 14,
  clipText = TRUE,
  styleText = list("font-size" = "70%"),
  tile = htmlwidgets::JS("d3.treemapBinary"),
  elementId = "tree"
)

# use tasks to color by toxicity
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
    });
}
"
  ),
  htmlwidgets::JS(
"
function(){
  var el = this.el;
  var x = this.x;

  $.contextMenu({
    selector: '#' + el.id + ' g.cell',
    build: function($trigger, e) {
      // this callback is executed every time the menu is to be shown
      // its results are destroyed every time the menu is hidden
      // e is the original contextmenu event, containing e.pageX and e.pageY (amongst other data)
      return {
        callback: function(key, options) {
          var data = d3.select(this[0]).datum().data[x.labelField];
          var m = 'clicked: ' + key +  ' ' + data;
          window.console && console.log(m);
          // I don't like this at all, but it does work
          switch(key) {
            case 'plot':
            //$('a[data-value=\"Plot\"]').tab('show');
            break;
            case 'table':
            //$('a[data-value=\"TradeByTrade\"]').tab('show');
            break;
          }
          Shiny.onInputChange(el.id + '_rightClickShiny', {
            key: key,
            data: data
          });
        },
        items: {
        //'edit': {name: 'Edit', icon: 'edit'},
        //'cut': {name: 'Cut', icon: 'cut'},
        //'copy': {name: 'Copy', icon: 'copy'},
        //'paste': {name: 'Paste', icon: 'paste'},
        //'delete': {name: 'Delete', icon: 'delete'},
        //'plot': {name: 'Plot TradeID', icon: 'copy'},
        'table': {name: 'Show Detail Table', icon: ''}
        // 'sep1': '---------',
        // 'quit': {name: 'Quit', icon: function($element, key, item){ return 'context-menu-icon context-menu-icon-quit'; }}
        }
      }
    }
  });
}
"
  )
)


#  add context menu
ctx_menu_dep <- htmlDependency(
  name = "jquery-contextMenu",
  version = "2.4.3",
  src = c(href = "https://swisnl.github.io/jQuery-contextMenu/dist/"),
  script = c("jquery.ui.position.min.js","jquery.contextMenu.js"),
  stylesheet = "jquery.contextMenu.css"
)

browsable(
  tagList(
    rmarkdown::html_dependency_jquery(),
    ctx_menu_dep,
    tr
  )
)

ui <- tagList(
  ctx_menu_dep,
  tr
)

server <- function(input, output, session) {
  observeEvent(
    input$tree_rightClickShiny,
    {
      print(input$tree_rightClickShiny)
    }
  )
}
shinyApp(ui,server)
