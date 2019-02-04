HTMLWidgets.widget({

  name: 'treezoom',

  type: 'output',

  factory: function(el, width, height) {

    var instance = {};

    function drawCells(data) {
      var x = instance.x;
      var layout = instance.layout;
      var chart_g = instance.chart_g;

      if(data.hasOwnProperty('data')) {
        data = data.data;
      }

      var root = layout(
        d3.hierarchy(data)
          .sum(function(d) {return d[x.sizeField] || 0;})
          .sort(function(a, b) {return b.value - a.value})
      );

      var cells = chart_g.selectAll('g.cell')
        .data(root.children);

      cells_enter = cells.enter()
        .append('g')
        .classed('cell', true);

      cells_enter.append('rect');
      cells_enter.append('text');

      cells.exit().transition()
        .style('opacity', 0)
        .remove();

      cells = cells.merge(
        cells_enter
      );

      cells.style("pointer-events", "all")
        .style('opacity', 0);

      cells.each(function() {
        var cell = d3.select(this);
        cell.select('rect').datum(cell.datum());
        cell.select('text').datum(cell.datum());
      });

      cells.selectAll("rect")
        .attr('x', function(d) { return d.x0; })
        .attr('y', function(d) { return d.y0; })
        .attr("width", function(d) { return d.x1 - d.x0; })
        .attr("height", function(d) { return d.y1 - d.y0; });

      // add Shiny
      if(typeof(Shiny) !== 'undefined' && Shiny.onInputChange) {
        var sendShiny = function() {
          var source = d3.select(this);
          Shiny.onInputChange(
            el.id + '_' + d3.event.type,
            {
              'label': source.datum().data[x.labelField],
              'path': root.path(source.datum()).map(
                function(d) {
                  return d.data[x.labelField]
                }
              )
            }
          )
        }
        cells.on('click', sendShiny);
        cells.on('mouseover', sendShiny);
        cells.on('mouseout', sendShiny);
      }

      cells.on('click', function(data) {
        zoomIn(this);
      });

      cells
        .selectAll('text')
        .text(function(d) {
          return d.data[x.labelField];
        })
        .attr('x', function(d) { return d.x0; })
        .attr('y', function(d) { return d.y0; })
        .attr('dx', '2px')
        .attr('dy', '1em')
        .style('fill', 'black')
        .style('stroke', 'none');

      if(x.style) {
        Object.keys(x.style).forEach(function(ky) {
          try {
            cells.style(ky, x.style[ky]);
          } catch(e) {
            console.log(e);
          }
        });
      }

      if(x.styleRect) {
        Object.keys(x.styleRect).forEach(function(ky) {
          try {
            cells.selectAll('rect').style(ky, x.styleRect[ky]);
          } catch(e) {
            console.log(e);
          }
        });
      }

      if(x.styleText) {
        Object.keys(x.styleText).forEach(function(ky) {
          try {
            cells.selectAll('text').style(ky, x.styleText[ky]);
          } catch(e) {
            console.log(e);
          }
        });
      }

      // attempt to delete text that does not fit in cell
      if(x.clipText) {
        cells.each(function(d) {
          var cell = this;
          var text = d3.select(this).select('text');
          var width = cell.getBoundingClientRect().width;
          var height = cell.getBoundingClientRect().height;
          if(
            text.node().getComputedTextLength() + 1 > d.x1 - d.x0 ||
            text.node().getBoundingClientRect().height > d.y1 - d.y0
          ) {
            text.text('');
          }
        });
      }

      cells
        .transition()
        .style('opacity', 1);

      // set up a container for tasks to perform after completion
      //  one example would be add callbacks for event handling
      //  styling
      if (typeof x.tasks !== "undefined") {
        if ( (typeof x.tasks.length === "undefined") ||
         (typeof x.tasks === "function" ) ) {
           // handle a function not enclosed in array
           // should be able to remove once using jsonlite
           x.tasks = [x.tasks];
        }
        x.tasks.map(function(t){
          // for each tasks call the task with el supplied as `this`
          t.call({el:el,x:x,instance:instance});
        });
      }
    }

    function zoomIn(node) {
      var chart_g = instance.chart_g;
      var layout = instance.layout;

      var cell_zoom = d3.select(node);

      var child = cell_zoom.datum().copy();

      if(!(
        child.hasOwnProperty('children') &&
        Array.isArray(child.children) &&
        child.children.length > 0
      )) {
        return;
      }

      d3.select(el).selectAll('.cell').transition()
        .filter(function(cl) {
          return cl !== cell_zoom.datum();
        })
        .style('opacity', 0)
        .remove();

      var transition = cell_zoom.transition()
        .duration(1200);

      transition.select('rect')
          .attr('x', 0)
          .attr('y', 0)
          .attr("width", function(d) { return layout.size()[0]; })
          .attr("height", function(d) { return layout.size()[1]; });

      transition.select('text')
          .attr('x', 0)
          .attr('y', 0);

      transition.remove();

      transition.end().then(function() {
        drawCells(child);
      });
    }

    function findNode(name, root) {
      var x = instance.x;
      var labelField = x.labelField;
      var found = root.descendants().filter(function(node) {
        return node.data[labelField] === name;
      });

      if(Array.isArray(found) && found.length > 0) {
        found = found[0];
      }

      return found;
    }

    function zoomOut(name) {
      var chart_g = instance.chart_g;
      var layout = instance.layout;
      var root = instance.root;

      var node = findNode(name, root);
      var current = findNode(
        d3.select(el).select('.cell').datum().parent.data[instance.x.labelField],
        root
      );
      if(typeof(node) === "undefined") {
        return;
      }
      node = node.copy();

      var cells = chart_g.selectAll('g.cell')
        .data(current.children);

      cells.each(function() {
        var cell = d3.select(this);
        cell.select('rect').datum(cell.datum());
        cell.select('text').datum(cell.datum());
      });

      var transition = cells.transition()
        .duration(1200);

      transition.selectAll('rect')
        .attr('x', function(d) { return d.x0; })
        .attr('y', function(d) { return d.y0; })
        .attr("width", function(d) { return d.x1 - d.x0; })
        .attr("height", function(d) { return d.y1 - d.y0; });

      transition.selectAll('text')
        .attr('x', function(d) { return d.x0 })
        .attr('y', function(d) { return d.y0 });

      var t2 = transition.transition()
        .style('opacity', 0)
        .remove();

      t2.end().then(function() {
        drawCells(node);
      });
    }

    return {

      renderValue: function(x) {
        // add accessor for updating from JavaScript
        instance.x = x;

        // calculate height and width to match
        //   size of the containing element
        var width = el.getBoundingClientRect().width;
        var height = el.getBoundingClientRect().height;

        var margin = x.margin ? x.margin : {left:0, top:0, right:0, bottom:0};

        // set up treemap layout
        var layout = d3.treemap()
          .size([
            width - margin.left - margin.right,
            height - margin.top - margin.bottom
          ]);
        instance.layout = layout;

        if(x.options) {
          Object.keys(x.options).forEach(function(ky) {
            try {
              layout[ky](x.options[ky]);
            } catch(e) {
              console.log(e);
            }
          });
        }

        x.sizeField ? x.sizeField = x.sizeField : x.sizeField = 'value';
        x.labelField ? x.labelField = x.labelField : x.labelField = 'name';

        // store root in instance for zoom out
        var root = layout(
          d3.hierarchy(x.data)
            .sum(function(d) {return d[x.sizeField] || 0;})
            .sort(function(a, b) {return b.value - a.value})
        );
        instance.root = root;

        // create svg and attach data
        var chart_g = d3.select(el).selectAll('g.chart')
          .data([x.data]);


        chart_g.exit().remove();

        chart_g_enter = chart_g.enter().append('svg')
          .append('g')
            .classed('chart', true)
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        chart_g = chart_g.merge(
          chart_g_enter
        );

        chart_g.each(function() {
          d3.select(this.parentNode)
            .style('width', width)
            .style('height', height);
        });

        instance.chart_g = chart_g;

        drawCells(x.data, instance);

      },

      resize: function(width, height) {

        this.renderValue(instance.x);

      },

      instance: instance,

      findNode: findNode,

      zoomIn: zoomIn,

      zoomOut: zoomOut

    };
  }
});
