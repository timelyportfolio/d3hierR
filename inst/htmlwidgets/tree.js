HTMLWidgets.widget({

  name: 'tree',

  type: 'output',

  factory: function(el, width, height) {

    var instance = {};

    return {

      renderValue: function(x) {
        // add accessor for updating from JavaScript
        instance.x = x;

        // calculate height and width to match
        //   size of the containing element
        var width = el.getBoundingClientRect().width;
        var height = el.getBoundingClientRect().height;

        // set up treemap layout
        var layout = d3.treemap()
          .size([width, height]);

        if(x.options) {
          Object.keys(x.options).forEach(function(ky) {
            try {
              layout[ky](x.options[ky]);
            } catch(e) {
              console.log(e);
            }
          });
        }

        x.sizeField ? x.sizeField : 'value';
        var root = layout(
          d3.hierarchy(x.data)
            .sum(function(d) {return d[x.sizeField] || 0;})
            .sort(function(a, b) {return b.value - a.value})
        );

        // create svg and attach data
        var chart_g = d3.select(el).selectAll('g.chart')
          .data([root.descendants()]);

        chart_g.exit().remove();

        chart_g_enter = chart_g.enter().append('svg')
          .append('g')
            .classed('chart', true);

        chart_g = chart_g.merge(
          chart_g_enter
        );

        chart_g.each(function() {
          d3.select(this.parentNode)
            .style('width', width)
            .style('height', height);
        });

        var cells = chart_g.selectAll('g.cell')
          .data(root.descendants().slice(1));

        cells_enter = cells.enter()
          .append('g')
          .classed('cell', true)
          .attr('transform', function(d) {
            return 'translate(0,' + d.y0 + ')';
          });

        cells_enter.append('rect');
        cells_enter.append('text');

        cells.exit().remove();

        cells = cells.merge(
          cells_enter
        );

        cells.each(function() {
          var cell = d3.select(this);
          cell.select('rect').datum(cell.datum());
          cell.select('text').datum(cell.datum());
        });

        cells
          .transition()
          .attr('transform', function(d) {
            return 'translate(' + d.x0 + ',' + d.y0 + ')';
          })
          .selectAll("rect")
            .attr("width", function(d) { return d.x1 - d.x0; })
            .attr("height", function(d) { return d.y1 - d.y0; });

        x.labelField = x.labelField ? x.labelField : 'name';

        cells
          .selectAll('text')
          .text(function(d) {
            return d.data[x.labelField];
          })
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
          })
        }

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
      },

      resize: function(width, height) {

        this.renderValue(instance.x);

      },

      instance: instance

    };
  }
});
