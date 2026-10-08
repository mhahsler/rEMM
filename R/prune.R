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


#' Prune States and/or Transitions
#'
#' @name prune
#' @rdname prune
#' @aliases prune
#' @aliases prune,EMM-method
#' @aliases rare_clusters
#' @aliases rare_clusters,tNN-method
#' @aliases rare_transitions
#' @aliases rare_transitions,TRACDS-method
#' @description Simplifies an EMM and/or the clustering by removing all
#' clusters/states and/or transitions
#' which have a count of equal or smaller than a given threshold.
#' @param x an object of class \code{"EMM"}
#' @param count_threshold all states/edges with a count of less or equal to the
#'   threshold are removed from the model.
#' @param clusters logical; prune clusters?
#' @param transitions logical; prune transitions?
#' @param copy logical; make a copy of x before reclustering? Otherwise the function will change \code{x}!
#' @param compact logical; tries make the data structure used for the temporal model more compact after pruning.
#' @param ... further arguments (currently not used).
#' @return \code{prune} returns invisibly an object of class \code{EMM}.
#'     If \code{copy=FALSE} then it returns a reference to the changes
#'     object passed as \code{x}.
#'
#'     \code{rare_clusters} returns a vector of names of rare clusters.
#'
#'     \code{rare_transitions} returns a data.frame of rare transitions.
#' @seealso \code{\link{remove_transitions}},
#' \code{\link{remove_clusters}},
#' \code{\link{compact}}
#' @examples data("EMMTraffic")
#'
#' ## For the example we use a very high learning rate
#' emm_l <- EMM(threshold=0.2, measure="eJaccard", lambda = 1)
#' build(emm_l, EMMTraffic)
#'
#' ## show state counts and transition counts
#' cluster_counts(emm_l)
#' transition_matrix(emm_l, type="counts")
#'
#' ## rare state/transitions
#' rare_clusters(emm_l, count_threshold=0.1)
#' rare_transitions(emm_l, count_threshold=0.1)
#'
#' ## remove all states with a threshold of 0.1
#' emm_lr <- prune(emm_l, count_threshold=0.1)
#'
#' ## compare graphs
#' op <- par(mfrow = c(1, 2), pty = "m")
#' plot(emm_l, main = "EMM with high learning rate")
#' plot(emm_lr, main = "Simplified EMM")
#' par(op)
#' @keywords manip
setMethod("prune", signature(x = "EMM"),
  function(x,
    count_threshold,
    clusters = TRUE,
    transitions = FALSE,
    copy = TRUE,
    compact = TRUE) {
    if (copy)
      x <- copy(x)

    if (clusters && nclusters(x) > 0)
      x <- remove_clusters(x,
        rare_clusters(x, count_threshold = count_threshold),
        copy = FALSE)

    if (transitions && ntransitions(x) > 0)
      x <- remove_transitions(x,
        rare_transitions(x, count_threshold = count_threshold),
        copy = FALSE)

    if (compact)
      x <- compact(x)

    if (copy)
      x
    else
      invisible(x)
  })
