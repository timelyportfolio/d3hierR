#' 'd3 v4 Zooomable Treemap htmlwidget'
#'
#' Create a d3 v4 based treemap htmlwidget
#'  as a foundation for other interactivity
#'
#' @import htmlwidgets
#'
#' @export
treezoom <- function(
  data = NULL,
  sizeField = "value",
  valueField = NULL,
  labelField = "name",
  style = list("fill" = "none", stroke = "black"),
  styleRect = NULL,
  styleText = NULL,
  clipText = FALSE,
  margin = list(
    left = 0, top = 0, right = 0, bottom = 0
  ),
  ...,
  width = '100%', height = NULL, elementId = NULL
) {

  # forward options using x
  x = list(
    data = data,
    style = style,
    styleRect = styleRect,
    styleText = styleText,
    sizeField = sizeField,
    valueField = valueField,
    labelField = labelField,
    clipText = clipText,
    margin = margin,
    options = list(
      ...
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'treezoom',
    x,
    width = width,
    height = height,
    package = 'd3hierR',
    elementId = elementId
  )
}

#' Shiny bindings for treezoom
#'
#' Output and render functions for using treezoom within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a treezoom
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name treezoom-shiny
#'
#' @export
treezoomOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'treezoom', width, height, package = 'd3hierR')
}

#' @rdname tree-shiny
#' @export
renderTreeZoom <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, treezoomOutput, env, quoted = TRUE)
}


#' @keywords internal
treezoom_html <- function(id, style, class, ...){
  htmltools::attachDependencies(
    htmltools::tagList(
      htmltools::tags$div(id=id, style=style, class=class, ...)
    ),
    d3r::d3_dep_v5()
  )
}
