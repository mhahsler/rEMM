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


## clustering = TRUE gets integer in to_merge
setMethod("merge_clusters", signature(x = "EMM", to_merge = "integer"),
  function(x,
    to_merge,
    clustering = FALSE,
    new_center = NULL,
    copy = TRUE) {
    if (copy)
      x <- copy(x)

    ## handle a clustering
    if (!clustering)
      stop("to_merge needs to be all character!")
    k <- max(to_merge)

    if (!is.null(new_center) && nrow(new_center) != k)
      stop("new_center has not the right number of rows.")

    orig_states <- clusters(x)

    for (i in 1:k) {
      m <- orig_states[to_merge == i]
      if (length(m) > 1)
        merge_clusters(x, m, clustering = FALSE,
          new_center[i, ], copy = FALSE)
    }

    invisible(x)
  })

## clustering = FALSE gets character
#' Merge States of an EMM
#'
#' @name merge_clusters
#' @rdname merge
#' @aliases merge_clusters
#' @aliases merge_clusters,EMM,character-method
#' @aliases merge_clusters,EMM,integer-method
#' @description Merge several clusters/states of an EMM into a single cluster/state.
#' @param x an \code{"EMM"} object. Note that the function will change this EMM!
#' @param to_merge vector of names of the states/clusters to merge. The
#'       name of the first state in \code{to_merge}
#'       is used as the name for the new state representing the merged states.
#' @param clustering is \code{to_merge} a vector with
#'   cluster assignments as created by a clustering algorithm?
#' @param new_center supply new centers for the merged clusters.
#'     New centroids are automatically
#'     computed. If (pseudo) medoids are used, new medoids should be supplied.
#'     If none is supplied, the medoid of the cluster in \code{to_merge}
#' 	which has the most assigned observations
#'     is used as the new medoid (warning: this is probably not a good medoid!)
#' @param copy logical; make a copy of x before reclustering? Otherwise the function will change \code{x}!
#' @return Returns the changed EMM with the states/clusters merged invisibly.
#' 	If \code{copy=FALSE} then it returns a reference to the changes
#' 	object passed as \code{x}.
#' @examples data("EMMTraffic")
#' emm <- EMM(measure="eJaccard", threshold=0.2)
#' build(emm, EMMTraffic)
#' states(emm)
#'
#' ## create a new emm with states 1-3 merged
#' emm_m123 <- merge_clusters(emm, c("1", "2", "3"))
#' states(emm_m123)
#' @keywords manip
setMethod("merge_clusters", signature(x = "EMM", to_merge = "character"),
  function(x,
    to_merge,
    clustering = FALSE,
    new_center = NULL,
    copy = TRUE) {
    if (copy)
      x <- copy(x)

    if (clustering)
      stop("to_merge has the wrong format for clustering!")

    if (!all(is.element(to_merge, clusters(x))))
      stop("not all clusters in to_merge exist in x!")

    ## nothing to do
    if (length(to_merge) < 2)
      return(x)

    new_state <- to_merge[1]
    to_delete <- states(x) %in% to_merge[-1]


    ## TRACDS
    x@tracds_d$mm <- smc_mergeStates(x@tracds_d$mm, to_merge)

    if (x@tracds_d$current_state %in% to_merge[-1])
      x@tracds_d$current_state <- new_state

    ## tNN
    ## save old state centers
    old_centers <- cluster_centers(x)[to_merge, ]

    ## create new state
    if (is.null(new_center)) {
      if (x@centroids) {
        x@tnn_d$centers[new_state, ] <-
          colSums(old_centers * x@tnn_d$counts[to_merge]) /
          sum(x@tnn_d$counts[to_merge])
      } else {
        ## we take the medoid of the larger cluster
        x@tnn_d$centers[new_state, ] <-
          old_centers[which.max(cluster_counts(x)[to_merge]), ]
      }
    } else{
      ## user supplied new center
      if (identical(length(new_center), ncol(x@tnn_d$centers)))
        x@tnn_d$centers[new_state, ] <- new_center
      else
        stop("new_center does not have the correct length/ncol!")
    }


    x@tnn_d$counts[new_state] <- sum(x@tnn_d$counts[to_merge])

    x@tnn_d$centers <- x@tnn_d$centers[!to_delete, , drop = FALSE]
    x@tnn_d$counts <- x@tnn_d$counts[!to_delete]



    ## FIXME: this only works for metric dissimilarities (distances)
    ## new threshold is max. dissimilarity vom new centroid to any old
    ## centroid + its threshold

    d <- dist(cluster_centers(x)[new_state, , drop = FALSE],
      old_centers, method = x@measure)[1, ]

    new_threshold <- max(d + x@tnn_d$var_thresholds[names(d)])
    names(new_threshold) <- new_state

    x@tnn_d$var_thresholds[new_state] <- new_threshold

    ## remove var. thresholds
    x@tnn_d$var_thresholds <- x@tnn_d$var_thresholds[!to_delete]

    invisible(x)
  })
