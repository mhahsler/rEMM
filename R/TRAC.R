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


## create a tNN clustering from k-means, etc.
## This is TRAC (without DS)

#' TRAC: Creating a Markov Model from a Regular Clustering
#'
#' @name TRAC
#' @rdname TRAC-class
#' @aliases TRAC
#' @description Create an Markov model from a regular clustering (k-means or PAM) of
#' sequence data.
#' @param x a clustering object (result of kmeans or PAM), a
#'     data set (a data matrix), or a vector with (integer) cluster assignments.
#' @param data the data used for clustering (only used if \code{x}
#'     is a cluster assignment vector).
#' @param centers if \code{x} is a cluster assignment vector, then a data.frame or matrix with the cluster centers needs to be supplies. Otherwise, \code{centers} is ignored.
#' @param measure used distance measure.
#' @details The order is inferred from the order in the original data set.
#' @return A \code{EMM} object representing the clustering of sequence data.
#' @examples data("EMMsim")
#'
#' ## using kmeans
#' cl <- kmeans(EMMsim_train, 10)
#' emm <- TRAC(cl)
#' emm
#' plot(emm, method = "MDS")
#'
#' ## using a cluster assignment vector (taken from the k-means clustering above)
#' x <- cl$cluster
#' emm <- TRAC(x, data = EMMsim_train)
#' emm
#' plot(emm, method = "MDS")
#' @keywords models
#' @export
TRAC <-
  function(x,
    data = NULL,
    centers = NULL,
    measure = "euclidean") {
    if (is(x, "kmeans")) {
      counts <- x$size
      k <- length(counts)
      centers <- x$centers
      thresholds <- sqrt(x$withinss / x$size) * 3
      order <- x$cluster

      ### PAM
    } else if (is(x, "partition")) {
      counts <- x$clusinfo[, "size"]
      k <- length(counts)
      centers <- x$medoids
      thresholds <- x$clusinfo[, "max_diss"]
      order <- x$cluster

      ### x must be a cluster index vector
    } else if (is.numeric(x)) {
      if (is.null(data) &&
          is.null(centers))
        stop("Either data or centers need to be specified.")

      order <- as.integer(x)
      k <- max(order, na.rm = TRUE)
      counts <- tabulate(order, k)


      if (!is.null(centers)) {
        if (!nrow(centers) != k)
          stop("Number of clusters and number of centers do not agree!")
        ### centers already are set

      } else{
        ### data is given
        centers <- t(sapply(
          1:k,
          FUN = function(i)
            colMeans(data[order == i, , drop = FALSE], na.rm = TRUE)
        ))
        thresholds <- sapply(
          1:k,
          FUN = function(i)
            max(dist(centers[i, , drop = FALSE],
              data[order == i, , drop = FALSE], method = measure), na.rm = TRUE)
        )
      }

    } else
      stop("Needs to be a kmeans or partition (PAM) object or a cluster vector and the used data.")

    emm <- new("EMM",
      measure = measure,
      threshold = max(thresholds))

    ## create tNN
    states <- as.character(1:k)
    names(counts) <- states
    rownames(centers) <- states
    names(thresholds) <- states

    emm@tnn_d$centers <- centers
    emm@tnn_d$counts <- counts
    emm@tnn_d$var_thresholds <- thresholds

    ## update TRACDS
    ## make sure the order of states corresponds to tNN
    emm@tracds_d$mm <- smc_addState(emm@tracds_d$mm, states)
    update(emm, order)

    emm
  }
