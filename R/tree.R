#' 'd3 v4 Treemap htmlwidget'
#'
#' Create a d3 v4 based treemap htmlwidget
#'  as a foundation for other interactivity
#'
#' @import htmlwidgets
#'
#' @export
tree <- function(
  data = NULL,
  sizeField = "value",
  valueField = "value",
  labelField = "name",
  style = list("fill" = "none", stroke = "black"),
  ...,
  width = '100%', height = NULL, elementId = NULL
) {

  # forward options using x
  x = list(
    data = data,
    style = style,
    sizeField = sizeField,
    valueField = valueField,
    labelField = labelField,
    options = list(
      ...
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'tree',
    x,
    width = width,
    height = height,
    package = 'd3hierR',
    elementId = elementId
  )
}

#' Shiny bindings for tree
#'
#' Output and render functions for using tree within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a tree
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name tree-shiny
#'
#' @export
treeOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'tree', width, height, package = 'd3hierR')
}

#' @rdname tree-shiny
#' @export
renderTree <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, treeOutput, env, quoted = TRUE)
}


#' @keywords internal
tree_html <- function(id, style, class, ...){
  htmltools::attachDependencies(
    htmltools::tagList(
      htmltools::tags$div(id=id, style=style, class=class, ...)
    ),
    d3r::d3_dep_v4()
  )
}
