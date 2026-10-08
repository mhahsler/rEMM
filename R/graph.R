## igraph coercions
#' @rdname TRACDS-class
#' @param object A \code{TRACDS} or \code{EMM} object.
#' @export
as.igraph <-  function(object)
  UseMethod("as.igraph")

#' @rdname TRACDS-class
#' @export as.igraph.TRACDS
#' @exportS3Method as.igraph TRACDS
as.igraph.TRACDS <-
  function(object)
    smc_as.igraph(object@tracds_d$mm)


## graph coercions
#' @rdname TRACDS-class
#' @param object A \code{TRACDS} or \code{EMM} object.
#' @export
as.graph <-  function(object)
  UseMethod("as.graph")

#' @rdname TRACDS-class
#' @export as.graph.TRACDS
#' @exportS3Method as.graph TRACDS
as.graph.TRACDS <-  function(object) {
  if (!.installed("graph"))
    stop ("Package graph needed! Please install from Bioconductor.")
  smc_as.graph(object@tracds_d$mm)
}
