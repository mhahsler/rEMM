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

### smooth transitions: Each cluster gets the average of the outgoing
### transition counts of all its neightbors = within range x threshold

#' Smooths transition counts between neighboring states/clusters
#'
#' @name smooth_transitions
#' @rdname smooth_transitions
#' @aliases smooth_transitions
#' @aliases smooth_transitions,EMM-method
#' @description Each state/cluster gets the average count if all the outgoing transitions of
#' its neighbors (i.e., clusters which are within range x its threshold).
#' @param x an object of class \code{"EMM"}
#' @param range threshold multiplier for the smoothing range.
#' @param copy logical; make a copy of x before reclustering? Otherwise the function will change \code{x}!
#' @return \code{smooth_transitions} returns invisibly an object of class \code{EMM}.
#'     If \code{copy=FALSE} then it returns a reference to the changes
#'     object passed as \code{x}.
#' @seealso \code{\link{prune}}
#' @examples data("EMMTraffic")
#'
#' ## learn a model
#' emm <- EMM(threshold=0.2, measure="eJaccard")
#' build(emm, EMMTraffic)
#'
#' ## smooth the model by adding tansitions
#' emm_s <- smooth_transitions(emm)
#'
#' ## compare graphs
#' op <- par(mfrow = c(1, 2), pty = "m")
#' plot(emm, method="MDS", main="Original")
#' plot(emm_s, method="MDS", main="Smoothed")
#' par(op)
#' @keywords manip
setMethod("smooth_transitions", signature(x = "EMM"),
  function(x, range = 2, copy = TRUE) {
    if (copy)
      x <- copy(x)

    centers <- cluster_centers(x)
    tm <- transition_matrix(x, type = "counts")
    tms <- matrix(NA_real_, nrow = nrow(tm), ncol = ncol(tm))

    for (i in 1:nclusters(x)) {
      d <- dist(centers[i, , drop = FALSE], centers, method = x@measure)
      tms[i, ] <-
        colMeans(tm[d <= range * x@tnn_d$var_thresholds, , drop = FALSE])
    }

    x@tracds_d$mm <- smc_setTransitions(
      x@tracds_d$mm,
      from = rep(clusters(x), nclusters(x)),
      to = rep(clusters(x), each = nclusters(x)),
      value = as.vector(tms)
    )

    if (copy)
      x
    else
      invisible(x)
  })
