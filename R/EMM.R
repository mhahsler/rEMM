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


## constructor
#' Creator for Class "EMM"
#'
#' @name EMM
#' @rdname EMM-class
#' @aliases EMM
#' @aliases object.size,EMM-method
#' @description Create a new object of class \code{"EMM"}.
#' @param threshold Object of class \code{"numeric"} with the dissimilarity threshold used by the
#' clustering algorithm for assigning a new observation to existing clusters.
#' @param measure Object of class \code{"character"} containing the name of the dissimilarity
#' measure used (see \code{dist} in \pkg{proxy} for available measures).
#' @param distFun Specify a function passed on as method to \code{dist} in \pkg{proxy}
#' (see \code{dist} in \pkg{proxy}).
#' The character string passed on as \code{measure} will be used as the
#' measure's name.
#' @param centroids Object of class \code{"logical"} indicating if centroids are used for clusters.
#' If \code{FALSE}, pseudo medians (first observation of a cluster) are used to
#' represent a cluster.
#' @param lambda Object of class \code{"numeric"} specifying the
#'                  rate for fading.
#' @param data Initial data to build the EMM.
#'     This just calls \code{build} on the new EMM.
#' @return An object of class \code{"EMM"}.
#' @seealso \code{\link{EMM-class}}
#' @examples ## load EMMTraffic data
#' data(EMMTraffic)
#'
#' ## create empty EMM
#' emm <- EMM(threshold=0.2, measure="eJaccard", lambda=.1)
#' emm
#'
#' ## cluster some data
#' build(emm, EMMTraffic)
#' emm
#'
#' ## what clusters were the data points assigned to?
#' last_clustering(emm)
#'
#' ## plot the clustering as a graph
#' plot(emm)
#' @keywords models
#' @export
EMM <- function(threshold = 0.2,
  measure = "euclidean",
  distFun = NULL,
  centroids = identical(tolower(measure), "euclidean"),
  lambda = 0,
  data = NULL) {
  emm <- new(
    "EMM",
    measure = measure,
    distFun = distFun,
    threshold = threshold,
    centroids = centroids,
    lambda = lambda
  )

  if (!is.null(data))
    build(emm, data)
  emm

}

### deep copy
setMethod("copy", signature(x = "EMM"),
  function(x) {
    r <- new(
      "EMM",
      threshold = x@threshold,
      measure = x@measure,
      distFun = x@distFun,
      centroids = x@centroids,
      lambda = x@lambda,
      lambda_factor = x@lambda_factor
    )

    ## copy environments
    r@tnn_d <- as.environment(as.list(x@tnn_d))
    r@tracds_d <- as.environment(as.list(x@tracds_d))

    r
  })


## show
setMethod("show", signature(object = "EMM"),
  function(object) {
    cat(
      "EMM with",
      size(object),
      "states/clusters.\n",
      "Measure:",
      object@measure,
      "\n",
      "Threshold:",
      object@threshold,
      "\n",
      "Centroid:",
      object@centroids,
      "\n",
      "Lambda:",
      object@lambda,
      "\n"
    )
    invisible(NULL)
  })

## size delegates to nclusters (in tNN)
setMethod("size", signature(x = "EMM"),
  function(x)
    nclusters(x))
