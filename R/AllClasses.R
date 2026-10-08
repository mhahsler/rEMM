#######################################################################
# rEMM - Extensible Markov Model (EMM) for Data Stream Clustering in R
# Copyright (C) 2011 Michael Hahsler
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#' @exportClass StreamClustering
#' @noRd
setClass("StreamClustering")

#' Class "tNN"
#'
#' @name tNN-class
#' @rdname tNN-class
#' @aliases tNN
#' @aliases tNN-class
#' @aliases StreamClustering-class
#' @aliases cluster_centers
#' @aliases cluster_centers,tNN-method
#' @aliases copy,tNN-method
#' @aliases cluster_counts
#' @aliases cluster_counts,tNN-method
#' @aliases clusters
#' @aliases clusters,tNN-method
#' @aliases nclusters
#' @aliases nclusters,tNN-method
#' @aliases last_clustering
#' @aliases last_clustering,tNN-method
#' @aliases plot,tNN,missing-method
#' @aliases object.size,tNN-method
#' @docType class
#' @description Implements the threshold Nearest Neighbor clustering algorithm
#' used by EMM.
#' @section Objects from the Class:
#' Objects can be created with \code{new()} or by the creator function
#' \code{tNN}.
#' @section Slots:
#' \describe{
#'     \item{\code{measure}:}{Object of class \code{"character"} containing
#' 		the name of the dissimilarity measure used
#' 		(see \code{dist} in \pkg{proxy} for available measures)}
#'     \item{\code{centroids}:}{Object of class \code{"logical"} indicating
#' 		if centroids are used for clusters. If \code{FALSE},
#' 		pseudo medians (first observation of a cluster) are used
#' 		to represent a cluster.}
#'     \item{\code{threshold}:}{Object of class \code{"numeric"}
#' 		with the dissimilarity threshold used
#' 	    by the NN clustering algorithm for assigning a new
#' 		observation to existing clusters.}
#'     \item{\code{lambda}:}{Object of class \code{"numeric"} specifying the
#' 		 rate for fading.}
#'     \item{\code{lambda_factor}:}{Object of class \code{"numeric"} expressing
#' 		the fading rate expressed as a factor.}
#'     \item{\code{tnn_d}:}{An environment containing the variable
#'     data for the tNN object:
#'   \describe{
#'     \item{\code{centers}:}{Object of class \code{"matrix"} containing
#' 		the cluster centers. }
#'     \item{\code{counts}:}{Object of class \code{"numeric"} with the
#' 		number of observations assigned to each cluster.}
#'     \item{\code{var_thresholds}:}{Object of class \code{"numeric"} with the
#' 		dissimilarity thresholds for individual clusters (usually
#' 		the same as threshold).}
#'     \item{\code{last}:}{A \code{"character"} vector containing the
#' 		cluster names the points for the previous call of
#' 		\code{cluster()} were assigned to.}
#'   }
#'     }
#' 	 }
#' @section Methods:
#' \describe{
#'       \item{copy}{\code{signature(x = "tNN")}: Make a copy of the tNN object.
#' 	  Making explicit copies is necessary since
#' 	  information is stored in an environment which is not copied
#' 	  for regular assignements.}
#'
#'
#'     \item{cluster_centers}{\code{signature(x = "tNN")}: returns the cluster
#' 	centers as a matrix.}
#'     \item{cluster_counts}{\code{signature(x = "tNN")}: returns the cluster
#' 	counts as a vector.}
#'     \item{clusters}{\code{signature(x = "tNN")}: returns the names of the
#' 	clusters.}
#'     \item{last_clustering}{\code{signature(x = "tNN")}: returns the
#' 	indices of the clusters the data points in the last cluster
#' 	operation where assigned to. To save memory the last clustering
#' 	information can be removed by setting the formal parameter
#' 	\code{remove} to \code{TRUE}.}
#'     \item{nclusters}{\code{signature(x = "tNN")}: returns the number of clusters
#' 	in the clustering.}
#'     \item{plot}{\code{signature(x = "tNN", y = "missing")}: plots the cluster
#' 	centers using a scatterplot matrix (see \code{pairs}).}
#' 	 }
#' @references M.H. Dunham, Y. Meng, J. Huang (2004): Extensible Markov Model, In:
#' \emph{ICDM '04: Proceedings of the Fourth IEEE International
#' Conference on Data Mining,} pp. 371--374.
#' @seealso \code{\link{cluster}} for adding new data to the clustering.
#' 	\code{\link{find_clusters}} to find the nearest neighbor cluster
#' 	    for given data points.
#' 	\code{\linkS4class{EMM}} extends "tNN".
#' @keywords classes
#' @exportClass tNN
setClass(
  "tNN",
  contains = ("StreamClustering"),
  representation(
    measure		= "character",
    distFun		= "ANY",
    centroids	= "logical",
    threshold	= "numeric",
    lambda		= "numeric",
    lambda_factor	= "numeric",
    ### this is all in an environment now
    #centers		= "matrix",	## row names are cluster names
    #counts		= "numeric",
    #var_thresholds	= "numeric",
    #last		= "character"
    tnn_d		= "environment"
  )

  ## FIXME: Implement check
  #validity= function(object) {}
)

setMethod("initialize", "tNN", function(.Object,
  threshold = 0.2,
  measure = "euclidean",
  distFun = NULL,
  centroids = identical(tolower(measure), "euclidean"),
  lambda = 0,
  ...) {
  .Object@threshold <- threshold
  .Object@measure <- measure
  .Object@centroids <- centroids
  .Object@lambda <- lambda
  .Object@lambda_factor <- 2 ^ (-lambda)

  .Object@tnn_d <- new.env()
  assign("centers", matrix(nrow = 0, ncol = 0), envir = .Object@tnn_d)
  assign("counts", numeric(), envir = .Object@tnn_d)
  assign("var_thresholds", numeric(), envir = .Object@tnn_d)
  assign("last", as.character(NA), envir = .Object@tnn_d)

  ### get dist function from proxy registry
  ### Note: this makes calling dist in proxy faster (no more lockup)
  if (!is.null(distFun))
    .Object@distFun <- distFun
  else
    .Object@distFun <- pr_DB[[measure]]

  #validObject(.Object)
  #.Object <- callNextMethod(.Object, ...)

  .Object
})



.smc_size <- 10L
setClass(
  "SimpleMC",
  representation(
    unused      = "integer",
    ## list of unused cols/rows
    top         = "integer",
    ## top of unused
    counts      = "matrix",
    initial_counts = "numeric"
  ),

  prototype(
    unused	    = .smc_size:1,
    top	    = .smc_size,
    counts	    = matrix(0, ncol = .smc_size, nrow = .smc_size),
    initial_counts = structure(rep(0, .smc_size),
      names = rep(NA, .smc_size))  ## also holds cluster names
  )

  ## FIXME: Implement check
  #validity= function(object) {
  #}
)

#' Class "TRACDS"
#'
#' @name TRACDS-class
#' @rdname TRACDS-class
#' @aliases TRACDS-class
#' @aliases TRACDS
#' @aliases as.igraph
#' @aliases as.igraph.TRACDS
#' @aliases as.graph
#' @aliases as.graph.TRACDS
#' @aliases current_state
#' @aliases current_state,TRACDS-method
#' @aliases nstates
#' @aliases nstates,TRACDS-method
#' @aliases ntransitions
#' @aliases ntransitions,TRACDS-method
#' @aliases copy,TRACDS-method
#' @aliases states
#' @aliases states,TRACDS-method
#' @aliases show,TRACDS-method
#' @aliases plot,TRACDS,missing-method
#' @aliases transitions
#' @aliases transitions,TRACDS-method
#' @aliases object.size,TRACDS-method
#' @docType class
#' @description Representation of the temporal structure of a data stream clustering using a extensible Markov model.
#' @section Objects from the Class:
#' Objects can be created using the creator function \code{TRACDS} or by
#' directly calling \code{new("TRACDS", ...)}. Most slots for the extended
#' classes can be used as parameters.
#' @section Slots:
#' \describe{
#' 	\item{\code{lambda}:}{Object of class \code{"numeric"} specifying the
#' 		 rate for fading.}
#'        \item{\code{lambda_factor}:}{Object of class \code{"numeric"} expressing
#' 		 the fading rate expressed as a factor.}
#'
#'    \item{\code{tracds_d}:}{An environment containing all the
#'     variable data of the TRACDS object:
#'       \describe{
#'       \item{\code{mm}:}{Object of class \code{"SimpleMC"} representing the
#' 		first order Markov model of the EMM. }
#'     \item{\code{current_state}:}{Object of class \code{"character"} with the
#' 		name of current state in the EMM. \code{NA} means
#' 			no current state.}
#'
#'
#'
#' 	 }}
#' 	 }
#' @section Methods:
#' \describe{
#'       \item{copy}{\code{signature(x = "TRACDS")}: Make a copy of the TRACDS object.
#' 	  Making explicit copies is necessary since
#' 	      information is stored in an environment which is not copied for regular
#' 	      assignements.}
#'
#'     \item{current_state}{\code{signature(x = "TRACDS")}: returns the name of
#' 		the current state. }
#'
#'
#'     \item{nstates}{\code{signature(x = "TRACDS")}: returns the number of states.}
#'     \item{ntransitions}{\code{signature(x = "TRACDS")}: returns the number of transitions with a count larger than 0 stored in the object.}
#'     \item{plot}{\code{signature(x = "TRACDS", y = "missing")}: Plots the
#'     object as a directed graph.}
#'     \item{states}{\code{signature(x = "TRACDS")}: returns the names of the
#' 		states.}
#'
#'
#'
#'     \item{transitions}{\code{signature(x = "TRACDS")}: returns all transitions		as a matrix of state names with a from and a to column. }
#' 	 }
#' @references Michael Hahsler and Margaret H. Dunham. Temporal structure learning for clustering massive data streams in real-time. In \emph{SIAM Conference on Data Mining} (SDM11), pages 664--675. SIAM, April 2011. \doi{10.1137/1.9781611972818.57}
#'
#' M. Hahsler, M. H. Dunham (2010): rEMM: Extensible Markov Model for
#' Data Stream Clustering in R, \emph{Journal of Statistical Software,} 35(5), 1-31,
#' URL \doi{10.18637/jss.v035.i05}
#'
#' M.H. Dunham, Y. Meng, J. Huang (2004): Extensible Markov Model, In:
#' \emph{ICDM '04: Proceedings of the Fourth IEEE International
#' Conference on Data Mining,} pp. 371--374.
#' @note A TRACDS object can be coerced to igraph or graph objects using
#' \code{as.igraph}() and \code{as.graph()}.
#' @seealso Look at
#' 	\code{\link{transition}},
#' 	\code{\link{transition_matrix}} and
#' 	\code{\link{initial_transition}} to access the transition information in
#' 	the EMM.
#' 	\code{\link{predict}} is used to predict future states of an EMM.
#' 	\code{\linkS4class{EMM}} extends \code{"TRACDS"}.
#' @keywords classes
#' @exportClass TRACDS
setClass(
  "TRACDS",
  representation(
    lambda		= "numeric",
    lambda_factor	= "numeric",
    tracds_d    	= "environment"
    #mm		= "SimpleMC",
    #current_state	= "character"
  ),

  prototype(
    lambda		= 0,
    lambda_factor	= 1,
    tracds_d    	= emptyenv()
    #mm		= new("SimpleMC"),
    #current_state	= as.character(NA)
  ),

  ## FIXME: Implement check
  #validity= function(object) {
  #}
)

setMethod("initialize", "TRACDS", function(.Object, lambda = 0, ...) {
  .Object@lambda <- lambda
  .Object@lambda_factor <- 2 ^ (-lambda)

  .Object@tracds_d <-  new.env()
  assign("mm", new("SimpleMC"), envir = .Object@tracds_d)
  assign("current_state", as.character(NA), envir = .Object@tracds_d)

  #cat("TRACDS initializes.\n")
  #validObject(.Object)

  #.Object <- callNextMethod(.Object, ...)

  .Object
})


### EMM is a subclass of tNN and TRACDS
#' Class "EMM"
#'
#' @name EMM-class
#' @rdname EMM-class
#' @aliases EMM-class
#' @aliases show,EMM-method
#' @aliases size
#' @aliases size,EMM-method
#' @aliases copy
#' @aliases copy,EMM-method
#' @docType class
#' @description This class represents the extensible Markov Model.	It consists
#' of a simple data stream clustering algorithm (class \code{"tNN"}) and
#' a temporal layer (class \code{"TRACDS"}).
#' @section Objects from the Class:
#' Objects can be created using the creator function \code{EMM} or by
#' directly calling \code{new("EMM", ...)}. Most slots for the extended
#' classes can be used as parameters for \code{EMM}.
#' @section Slots:
#' The slots are described in corresponding the extended classes
#' 	(see section Extends).
#' @section Extends:
#' Class \code{"\linkS4class{tNN}"}, directly.
#' Class \code{"\linkS4class{TRACDS}"}, directly.
#' @section Methods:
#' \describe{
#'     \item{copy}{\code{signature(x = "EMM")}: Make a copy of the EMM object.
#'     Making explicit copies is necessary since the subclasses store
#'     information in environments which are not copied for regular
#'     assignements.}
#'     \item{size}{\code{signature(x = "EMM")}: Returns the size of
#'     the EMM (number of clusters/states).}
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#' 	 }
#' @references M.H. Dunham, Y. Meng, J. Huang (2004): Extensible Markov Model, In:
#' \emph{ICDM '04: Proceedings of the Fourth IEEE International
#' Conference on Data Mining,} pp. 371--374.
#' @seealso \code{\link{build}},
#' 	\code{\link{fade}},
#' 	\code{\link{merge_clusters}},
#' 	\code{\link{plot}},
#' 	\code{\link{prune}},
#' 	\code{\link{rare_clusters}},
#' 	\code{\link{rare_transitions}},
#' 	\code{\link{remove_clusters}},
#' 	\code{\link{remove_transitions}},
#' 	\code{\link{remove_selftransitions}},
#' 	\code{\link{recluster}}, and
#' 	\code{\link{score}}.
#' @keywords classes
#' @exportClass EMM
setClass("EMM", contains = c("TRACDS", "tNN"))

## S4 BUG!!! R seems to only call initialize for the first class in contains
setMethod("initialize", "EMM", function(.Object, ...) {
  #threshold, measure, lambda,
  #	centroids, ...){

  #.Object <- callNextMethod(.Object, ...)

  #.Object@threshold <- threshold
  #.Object@measure <- measure
  #.Object@centroids <- centroids
  #.Object@lambda <- lambda
  #.Object@lambda_factor <- 2^(-lambda)

  .Object <- getMethod("initialize", "TRACDS")(.Object, ...)
  .Object <- getMethod("initialize", "tNN")(.Object, ...)

  validObject(.Object)

  .Object
})
