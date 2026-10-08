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


## creator function
#' @rdname tNN-class
#' @param threshold Numeric dissimilarity threshold for assigning new observations to existing clusters.
#' @param measure Name of the dissimilarity measure; see \code{\link[proxy]{dist}}.
#' @param centroids Logical; use centroids if \code{TRUE}, otherwise represent clusters by their first observation.
#' @param lambda Numeric fading rate. Zero disables fading.
#' @return An object of class \code{"tNN"}.
#' @export
tNN <- function(threshold = 0.2,
  measure = "euclidean",
  centroids = identical(tolower(measure), "euclidean"),
  lambda = 0) {
  new(
    "tNN",
    threshold = threshold,
    measure = measure,
    centroids = centroids,
    lambda = lambda
  )
}

## show
setMethod("show", signature(object = "tNN"),
  function(object) {
    cat(
      "tNN with",
      nclusters(object),
      "clusters.\n",
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


setMethod("copy", signature(x = "tNN"),
  function(x) {
    r <- new(
      "tNN",
      threshold = x@threshold,
      measure = x@measure,
      distFun = x@distFun,
      centroids = x@centroids,
      lambda = x@lambda,
      lambda_factor = x@lambda_factor
    )

    ## copy environment
    r@tnn_d <- as.environment(as.list(x@tnn_d))

    r
  })

## accessors

setMethod("cluster_counts", signature(x = "tNN"),
  function(x)
    x@tnn_d$counts)

setMethod("cluster_centers", signature(x = "tNN"),
  function(x)
    x@tnn_d$centers)

setMethod("nclusters", signature(x = "tNN"),
  function(x)
    nrow(x@tnn_d$centers))

## names are stored as the rownames of the centers
setMethod("clusters", signature(x = "tNN"),
  function(x)
    rownames(x@tnn_d$centers))

setMethod("last_clustering", signature(x = "tNN"),
  function(x, remove = FALSE) {
    lc <- x@tnn_d$last
    if (remove)
      x@tnn_d$last <- as.character(NA)
    lc
  })

setMethod("rare_clusters", signature(x = "tNN"),
  function(x, count_threshold)
    names(which(x@tnn_d$counts <= count_threshold)))


## find clusters
setMethod("find_clusters", signature(x = "tNN", newdata = "numeric"),
  function(x,
    newdata,
    match_cluster = c("exact", "nn"),
    dist = FALSE)
    find_clusters(x, as.matrix(rbind(newdata)), match_cluster, dist))

setMethod("find_clusters", signature(x = "tNN", newdata = "data.frame"),
  function(x,
    newdata,
    match_cluster = c("exact", "nn"),
    dist = FALSE)
    find_clusters(x, as.matrix(newdata), match_cluster, dist))

#' Find the EMM State/Cluster for an Observation
#'
#' @name find_clusters
#' @rdname find_clusters
#' @aliases find_clusters
#' @aliases find_clusters,tNN,numeric-method
#' @aliases find_clusters,tNN,matrix-method
#' @aliases find_clusters,tNN,data.frame-method
#' @description Finds the cluster and thus the EMM states for observations.
#' @param x an \code{EMM} object.
#' @param newdata a matrix/data.frame with observations.
#' @param match_cluster find exact or nearest neighbor (nn) cluster/state.
#'     If a number is supplied then the threshold times this number is
#'     used for exact matching.
#' @param dist also report the distance to the chosen cluster/state (as a
#'   data.frame).
#' @return Returns the name of the matching clusters/states or a data.frame with
#' columns "state" and "dist" if \code{dist=TRUE}.
#' @seealso \code{\linkS4class{EMM}} and \code{\linkS4class{tNN}}
#' @examples data("EMMTraffic")
#' emm <- EMM(measure="eJaccard", threshold=0.2)
#' emm <- build(emm, EMMTraffic)
#'
#' find_clusters(emm, EMMTraffic)
#' find_clusters(emm, EMMTraffic, dist=TRUE)
#'
#' ## add noise to the data
#' set.seed(1234)
#' newdata <- sapply(EMMTraffic, jitter, amount=15)
#' ## default is exact match
#' find_clusters(emm, newdata, dist=TRUE)
#' ## match with nearest neighbor
#' find_clusters(emm, newdata, match_cluster="nn", dist=TRUE)
#' ## exact match only if within .5 times threshold
#' find_clusters(emm, newdata, match_cluster=.5, dist=TRUE)
#' ## exact match only if within 2 times threshold
#' find_clusters(emm, newdata, match_cluster=2, dist=TRUE)
#' @keywords models
setMethod("find_clusters", signature(x = "tNN", newdata = "matrix"),
  function(x,
    newdata,
    match_cluster = c("exact", "nn"),
    dist = FALSE) {
    ## see if match_cluster is a threshold multiplier
    if (is.numeric(match_cluster)) {
      multiplier <- match_cluster
      match_cluster <- "exact"
    } else
      multiplier <- 1

    match_cluster <- match.arg(match_cluster)

    ## cross-dissimilarities
    ## matrix can become too large for main memory
    ## estimate block size with 64 bit per distance entry
    ## and dist computation takes about 5* the memory

    ## no clusters?
    if (nclusters(x) == 0)
      return(rep(NA, nrow(newdata)))

    maxmem <- 128L  ## max. approx. 128 MBytes
    blocksize <- as.integer(floor(maxmem * 1024 * 1024
      / nclusters(x) / 8 / 5))

    if (nrow(newdata) > 1 && nrow(newdata) > blocksize) {
      states <- character(nrow(newdata))
      if (dist)
        d_state <- numeric(nrow(newdata))

      blockStart <- 1L
      while (blockStart < nrow(newdata)) {
        blockEnd <- min(blockStart + blocksize - 1L, nrow(newdata))
        #cat("doing",blockStart,blockEnd,"\n")
        if (dist) {
          tmp <- find_clusters(x,
            newdata[blockStart:blockEnd, ],
            match_cluster, dist)

          states[blockStart:blockEnd] <-
            as.character(tmp[, 1])
          d_state[blockStart:blockEnd] <- tmp[, 2]

        } else
          states[blockStart:blockEnd] <- find_clusters(x,
            newdata[blockStart:blockEnd, ],
            match_cluster, dist)

        blockStart <- blockEnd + 1L
      }
      if (dist)
        return(data.frame(state = states, dist = d_state))
      else
        return(states)
    }

    ## do it in one run
    d <-
      dist(newdata, cluster_centers(x), method = x@distFun)

    .which.min_NA <- function(x) {
      m <- which.min(x)
      if (length(m) == 0)
        m <- NA
      m
    }

    if (match_cluster == "nn") {
      min <- apply(d, MARGIN = 1, .which.min_NA)
      closest <- clusters(x)[min]
      if (dist) {
        d_state <- sapply(
          1:nrow(newdata),
          FUN = function(i)
            d[i, min[i]]
        )
        return(data.frame(state = closest, dist = d_state))
      } else
        return(closest)
    }

    ## exact matching using thresholds (using the largest margin)
    ## NA ... no match

    ## subtract threshold and take the smallest value if <=0
    ## multiplier is applied to threshold
    d2 <- d - matrix(
      x@tnn_d$var_thresholds * multiplier,
      ncol = length(x@tnn_d$var_thresholds),
      nrow = nrow(d),
      byrow = TRUE
    )

    min <- apply(d2, MARGIN = 1, .which.min_NA)


    closest <- clusters(x)[min]
    closest_val <- sapply(
      1:nrow(newdata),
      FUN = function(i)
        d2[i, min[i]]
    )
    closest[closest_val > 0] <- NA


    if (dist) {
      d_state <- sapply(
        1:nrow(newdata),
        FUN = function(i)
          d[i, min[i]]
      )
      return(data.frame(state = closest, dist = d_state))
    } else
      return(closest)
  })
