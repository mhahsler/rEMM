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


## FIXME: find medoids for hclust

## medoid is defined as the object of a cluster, whose average
## dissimilarity to all the objects in the cluster is minimal
## min_{m\inC}(1/n_C sum_{i\inC\m}(d(i,m))
.find_medoids <- function(d, k, cl) {
  dm <- as.matrix(d)
  sapply(
    1:k,
    FUN = function(i) {
      take <- cl == i
      names(which.min(colSums(dm[take, take, drop = FALSE])))
    }
  )
}

## hierarchical clustering
#' Reclustering EMM states
#'
#' @name recluster
#' @rdname recluster
#' @aliases recluster
#' @aliases recluster_hclust
#' @aliases recluster_hclust,EMM-method
#' @aliases recluster_kmeans
#' @aliases recluster_kmeans,EMM-method
#' @aliases recluster_pam
#' @aliases recluster_pam,EMM-method
#' @aliases recluster_tNN
#' @aliases recluster_tNN,EMM-method
#' @aliases recluster_reachability
#' @aliases recluster_reachability,EMM-method
#' @aliases recluster_transitions
#' @aliases recluster_transitions,EMM-method
#' @description Use various clustering methods to recluster states/clusters
#' in an EMM. The centers of the clusters in the EMM object are used as
#' data points by the reclustering algorithm. States/centers put by reclustering
#' into the same cluster are merged to produce a new reclustered EMM.
#' @param x an \code{"EMM"} object.
#' @param k number of clusters.
#' @param h heights where the dendrogram tree should be cut.
#' @param threshold threshold used on the dissimilarity to join
#'     clusters for tNN. If no threshold is specified then the threshold
#'     stored in the EMM is used.
#' @param method clustering method used by \code{hclust}.
#' @param ... additional arguments passed on to the clustering algorithm.
#' @param prune logical; prune states with less
#' 	than \code{prune} counts before reclustering.
#' @param copy logical; make a copy of x before reclustering? Otherwise the function will change \code{x}!
#' @details For \code{recluster_kmeans} \code{k} can also be a set of initial cluster
#' centers (see argument \code{centers} for \code{kmeans} in package \pkg{stats}).
#'
#' For \code{recluster_hclust} \code{k} or \code{h} can also be a vector.
#' The result is then a list with several (nested) EMMs, one for each value.
#'
#' For \code{recluster_reachability} reclusters all clusters which are reachable
#' from each other. A cluster \eqn{j} is reachable from \eqn{i} if
#' \eqn{j}'s center is closer to \eqn{i}'s center than \code{h} or if \eqn{j} is
#' reachable by any cluster reachable by \eqn{i}.
#'
#' For \code{recluster_tNN} reclusters such that two clusters with
#' centers less than the threshold apart will be reclustered into a
#' single cluster. This is useful, for example, after combining two models.
#'
#' For \code{recluster_transitions} does not recluster clusters!
#' It find groups of clusters which are overlapping (centers are
#' less than 2 thresholds apart) and then redistributes the transition weights
#' such that all members of one group are connected to all the members of the
#' other group using the same weight.
#' @return An object of class \code{"EMM"} or, if \code{copy=FALSE} a refernece
#' to the changed object passed as \code{x}.
#'
#' Clustering information is available
#' as the attribute \code{"cluster_info"}.
#' The information provided depends
#' in the clustering algorithm (see \code{hclust}, \code{kmeans} and \code{pam}).
#' @seealso \code{\link{merge_clusters}}, \code{\link{prune}},
#' 	\code{\link[stats]{kmeans}}, \code{\link[stats]{hclust}},
#' 	\code{\link[cluster]{pam}}
#' @examples data(EMMsim)
#' emm <- EMM(threshold = .2)
#' build(emm, EMMsim_train)
#'
#' ## do reclustering on a copy of the emm and plot dendrogram
#' emm_hc <- recluster_hclust(emm, h = 0.6)
#'
#' attr(emm_hc, "cluster_info")
#'
#' ## compare original and clustered EMM
#' op <- par(mfrow = c(2, 2), pty = "m")
#' plot(emm, method= "MDS", main ="original EMM", data = EMMsim_train)
#' plot(attr(emm_hc, "cluster_info")$dendrogram)
#' abline(h=0.6, col="red")
#' plot(emm_hc, method="MDS", main ="clustered EMM", data = EMMsim_train)
#' plot(emm_hc, method="MDS", main ="clustered EMM")
#' par(op)
#' @keywords manip
#' @keywords models
#' @keywords cluster
setMethod("recluster_hclust", signature(x = "EMM"),
  function(x,
    k = NULL,
    h = NULL,
    method = "average",
    ...,
    prune = NULL,
    copy = TRUE) {
    if (copy)
      x <- copy(x)

    if (!is.null(prune))
      x <- prune(
        x,
        count_threshold = prune,
        transitions = FALSE,
        copy = FALSE
      )

    d <- dist(cluster_centers(x), method = x@distFun)
    hc <- hclust(d, method = method, ...)
    cl <- cutree(hc, k = k, h = h)

    ## if only h was given
    if (is.null(k))
      k <- max(cl)

    if (is(cl, "matrix")) {
      x <- lapply(
        1:ncol(cl),
        FUN = function(i) {
          if (!x@centroids)
            new_center <- cluster_centers(x)[.find_medoids(d, k, cl[, i]), ]
          ## centroids are handled by merge_clusters!
          else
            new_center <- NULL

          merge_clusters(
            x,
            cl[, i],
            clustering = TRUE,
            new_center = new_center,
            copy = TRUE
          )
        }
      )
    } else{
      if (!x@centroids)
        new_center <- cluster_centers(x)[.find_medoids(d, k, cl), ]
      else
        new_center <- NULL

      merge_clusters(x,
        cl,
        clustering = TRUE,
        new_center = new_center,
        copy = FALSE)
    }

    attr(x, "cluster_info") <- list(clustering = cl, dendrogram = hc)

    if (copy)
      x
    else
      invisible(x)
  })

## k-means (euclidean)
#' @rdname recluster
setMethod("recluster_kmeans", signature(x = "EMM"),
  function(x,
    k,
    ...,
    prune = NULL,
    copy = TRUE) {
    if (copy)
      x <- copy(x)

    if (!is.null(prune))
      x <- prune(
        x,
        count_threshold = prune,
        transitions = FALSE,
        copy = FALSE
      )

    if (!identical(tolower(x@measure), "euclidean"))
      warning(paste(
        "Using k-means implies Euclidean distances but the EMM uses:",
        x@measure
      ))

    cl <- kmeans(cluster_centers(x), centers = k, ...)

    merge_clusters(
      x,
      cl$cluster,
      clustering = TRUE,
      new_center = cl$centers,
      copy = FALSE
    )

    attr(x, "cluster_info") <- cl

    if (copy)
      x
    else
      invisible(x)
  })

## Partitioning around medoids (k-medians)
#' @rdname recluster
setMethod("recluster_pam", signature(x = "EMM"),
  function(x,
    k,
    ...,
    prune = NULL,
    copy = TRUE) {
    if (copy)
      x <- copy(x)
    if (!is.null(prune))
      x <- prune(
        x,
        count_threshold = prune,
        transitions = FALSE,
        copy = FALSE
      )

    d <- dist(cluster_centers(x), method = x@distFun)
    cl <- pam(d, k = k, ...)

    medoids <- cluster_centers(x)[cl$medoids, ]

    merge_clusters(
      x,
      cl$clustering,
      clustering = TRUE,
      new_center = medoids,
      copy = FALSE
    )

    attr(x, "cluster_info") <- cl

    if (copy)
      x
    else
      invisible(x)
  })

## reachability
#' @rdname recluster
setMethod("recluster_reachability", signature(x = "EMM"),
  function(x,
    h,
    ...,
    prune = NULL,
    copy = TRUE) {
    if (copy)
      x <- copy(x)

    if (!is.null(prune))
      x <- prune(
        x,
        count_threshold = prune,
        transitions = FALSE,
        copy = FALSE
      )

    d <- as.matrix(dist(cluster_centers(x), method = x@distFun))

    # get adjecency matrix and find all paths
    a_mat <- d < h
    r_mat <- a_mat
    for (i in 1:size(x)) {
      r_mat <- r_mat %*% a_mat
      storage.mode(r_mat) <- "logical"
    }

    to_merge <- unique(apply(r_mat, MARGIN = 1, FUN = which))
    to_merge <- lapply(to_merge, as.character)

    for (i in 1:length(to_merge)) {
      m <- to_merge[[i]]
      if (length(m) > 1) {
        merge_clusters(x, to_merge = m, copy = FALSE)
      }
    }

    if (copy)
      x
    else
      invisible(x)
  })


## tNN
#' @rdname recluster
setMethod("recluster_tNN", signature(x = "EMM"),
  function(x,
    threshold = NULL,
    ...,
    prune = NULL,
    copy = TRUE) {
    if (copy)
      x <- copy(x)

    if (!is.null(prune))
      x <- prune(
        x,
        count_threshold = prune,
        transitions = FALSE,
        copy = FALSE
      )

    if (is.null(threshold))
      threshold <- x@threshold

    cl <- tNN(
      threshold = threshold,
      measure = x@measure,
      centroids = x@centroids,
      lambda = 0
    )

    cluster(cl, cluster_centers(x))
    assignments <- last_clustering(cl)

    merge_clusters(x,
      as.integer(assignments),
      clustering = TRUE,
      copy = FALSE)

    if (copy)
      x
    else
      invisible(x)
  })

## transitions: group all states which intersecting radius
## and then homogenizes transitions between groups.
## Note: does not cluster states!
#' @rdname recluster
setMethod("recluster_transitions", signature(x = "EMM"),
  function(x,
    threshold = NULL,
    ...,
    prune = NULL,
    copy = TRUE) {
    if (is.null(threshold))
      threshold <- 2 * x@threshold

    if (copy)
      x <- copy(x)

    if (!is.null(prune))
      x <- prune(
        x,
        count_threshold = prune,
        transitions = FALSE,
        copy = FALSE
      )

    d <- dist(cluster_centers(x), method = x@distFun)
    hc <- hclust(d, method = "single")

    ## FIXME: this ignores vat_thresholds for now!
    clusters <- cutree(hc, h = threshold)

    for (i in unique(clusters)) {
      cl <- which(clusters == i)
      ncl <- which(clusters != i)

      if (length(cl) > 1) {
        ### fix transitions between elements in group
        x@tracds_d$mm@counts[cl, cl] <- sum(x@tracds_d$mm@counts[cl, cl]) /
          length(cl)

        ### fix outgoing transitions
        x@tracds_d$mm@counts[cl, ncl] <- matrix(
          colSums(x@tracds_d$mm@counts[cl, ncl]) / length(cl),
          nrow = length(cl),
          ncol = length(ncl),
          byrow = TRUE
        )

        ### fix incoming transitions
        x@tracds_d$mm@counts[ncl, cl] <- matrix(
          rowSums(x@tracds_d$mm@counts[ncl, cl]) / length(cl),
          nrow = length(ncl),
          ncol = length(cl),
          byrow = FALSE
        )

      }
    }


    if (copy)
      x
    else
      invisible(x)
  })
