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


## These generics already exist:
## setGeneric("predict", function(object, ...) standardGeneric("predict"))
## setGeneric("plot", function(x, y, ...) standardGeneric("plot"))

## TRACDS
## size is also used in package arules
#' @export
#' @noRd
setGeneric("update", function(object, ...)
  standardGeneric("update"))
#' @export
#' @noRd
setGeneric("copy", function(x)
  standardGeneric("copy"))
#' @export
#' @noRd
setGeneric("compact", function(x)
  standardGeneric("compact"))
#' @export
#' @noRd
setGeneric("size", function(x, ...)
  standardGeneric("size"))
#' @export
#' @noRd
setGeneric("nclusters", function(x, ...)
  standardGeneric("nclusters"))
#' @export
#' @noRd
setGeneric("nstates", function(x, ...)
  standardGeneric("nstates"))
#' @export
#' @noRd
setGeneric("ntransitions", function(x, ...)
  standardGeneric("ntransitions"))
#' @export
#' @noRd
setGeneric("current_state", function(x)
  standardGeneric("current_state"))
#' @export
#' @noRd
setGeneric("states", function(x)
  standardGeneric("states"))
#' @export
#' @noRd
setGeneric("transitions", function(x)
  standardGeneric("transitions"))
#' @export
#' @noRd
setGeneric("transition", function(x, from, to, ...)
  standardGeneric("transition"))
#' @export
#' @noRd
setGeneric("transition_matrix", function(x, ...)
  standardGeneric("transition_matrix"))
#' @export
#' @noRd
setGeneric("transition_table", function(x, newdata, ...)
  standardGeneric("transition_table"))
#' @export
#' @noRd
setGeneric("initial_transition", function(x, ...)
  standardGeneric("initial_transition"))
#' @export
#' @name prune
#' @rdname prune
setGeneric("rare_transitions", function(x, count_threshold, ...)
  standardGeneric("rare_transitions"))
#' @export
#' @noRd
setGeneric("remove_transitions", function(x, from, to, copy = TRUE)
  standardGeneric("remove_transitions"))
#' @export
#' @noRd
setGeneric("remove_selftransitions", function(x, copy = TRUE)
  standardGeneric("remove_selftransitions"))
#' @export
#' @noRd
setGeneric("smooth_transitions", function(x, ...)
  standardGeneric("smooth_transitions"))


## tNN
#' @export
#' @noRd
setGeneric("cluster", function(x, newdata, ...)
  standardGeneric("cluster"))
#' @export
#' @noRd
setGeneric("clusters", function(x)
  standardGeneric("clusters"))
#' @export
#' @noRd
setGeneric("cluster_counts", function(x)
  standardGeneric("cluster_counts"))
#' @export
#' @noRd
setGeneric("last_clustering", function(x, ...)
  standardGeneric("last_clustering"))
#' @export
#' @noRd
setGeneric("cluster_centers", function(x)
  standardGeneric("cluster_centers"))
#' @export
#' @noRd
setGeneric("find_clusters", function(x, newdata, ...)
  standardGeneric("find_clusters"))
#' @export
#' @name prune
#' @rdname prune
setGeneric("rare_clusters", function(x, count_threshold, ...)
  standardGeneric("rare_clusters"))

## EMM
#' @export
#' @noRd
setGeneric("build", function(x, newdata, ...)
  standardGeneric("build"))
#' @export
#' @noRd
setGeneric("reset", function(x)
  standardGeneric("reset"))
#' @export
#' @noRd
setGeneric("score", function(x, newdata, ...)
  standardGeneric("score"))
#' @export
#' @noRd
setGeneric("fade", function(x, t, lambda)
  standardGeneric("fade"))
#' @export
#' @noRd
setGeneric("prune", function(x, ...)
  standardGeneric("prune"))
#' @export
#' @noRd
setGeneric("merge_clusters", function(x, to_merge, ...)
  standardGeneric("merge_clusters"))
#' @export
#' @noRd
setGeneric("remove_clusters", function(x, to_remove, copy = TRUE)
  standardGeneric("remove_clusters"))

#' @export
#' @noRd
setGeneric("object.size", function(x)
  standardGeneric("object.size"))

## FIXME: make it one recluster method
#' @export
#' @noRd
setGeneric("recluster_hclust", function(x, ...)
  standardGeneric("recluster_hclust"))
#' @export
#' @noRd
setGeneric("recluster_kmeans", function(x, ...)
  standardGeneric("recluster_kmeans"))
#' @export
#' @noRd
setGeneric("recluster_pam", function(x, ...)
  standardGeneric("recluster_pam"))
#' @export
#' @noRd
setGeneric("recluster_reachability", function(x, ...)
  standardGeneric("recluster_reachability"))
#' @export
#' @noRd
setGeneric("recluster_tNN", function(x, ...)
  standardGeneric("recluster_tNN"))
#' @export
#' @noRd
setGeneric("recluster_transitions", function(x, ...)
  standardGeneric("recluster_transitions"))
