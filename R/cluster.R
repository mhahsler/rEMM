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


## make  newdata a matrix (with a single row)
setMethod("cluster", signature(x = "tNN", newdata = "numeric"),
  function(x, newdata, verbose = FALSE)
    cluster(x,
      as.matrix(rbind(newdata), verbose)))

setMethod("cluster", signature(x = "tNN", newdata = "data.frame"),
  function(x, newdata, verbose = FALSE)
    cluster(x, as.matrix(newdata),
      verbose))

#' Data stream clustering with tNN
#'
#' @name cluster
#' @rdname cluster
#' @aliases cluster
#' @aliases cluster,tNN,data.frame-method
#' @aliases cluster,tNN,matrix-method
#' @aliases cluster,tNN,numeric-method
#' @description Cluster new data into an existing tNN object.
#' @usage cluster(x, newdata, ...)
#' @param x a \code{tNN} object. Note that this function canges the original object!
#' @param newdata a vector (one observation), or a matrix or data.frame
#'     (each row is an observation).
#' @param ... further arguments like \code{verbose}.
#' @details \code{cluster()} implements tNN clustering The dissimilarity between
#' 	the new observation and the centers of the clusters is calculated. The
#' 	new observation is assigned to the closest cluster if the dissimilarity
#' 	value is smaller than the threshold (for the state).  If no such state
#' 	exists, a new state is created for the observation. This simple
#' 	clustering algorithm is called nearest neighbor threshold nearest
#' 	neighbor (threshold NN).
#'
#' 	\code{NA}s are handled in the data by using only the other
#' 	dimensions if the data for dissimilarity computation
#' 	(see package~\pkg{proxy}).
#'
#' 	The clusters which the data points in the last \code{cluster()}
#' 	operation where assigned to can be retrieved using the method
#' 	\code{last_clustering()}.
#' @return A reference to the changed tNN object with the data added.
#' Note: tNN objects store all variable data in an environment which
#' enables us to update partial data without copying the whole object. Assignment
#' will not create a copy! Use the provided method \code{copy()}.
#' @seealso Class \code{\linkS4class{tNN}},
#' 	\code{\link{fade}} and \code{\link[proxy]{dist}}
#' 	in \pkg{proxy}.
#' @examples ## load EMMTraffic data
#' data(EMMTraffic)
#'
#' ## create empty clustering
#' tnn <- tNN(threshold = 0.2, measure = "eJaccard")
#' tnn
#'
#' ## cluster some data
#' cluster(tnn, EMMTraffic)
#' tnn
#'
#' ## what clusters were the data points assigned to?
#' last_clustering(tnn)
#'
#' ## plot the clustering as a scatterplot matrix of the cluster centers
#' plot(tnn)
#' @keywords models
#' @keywords cluster
setMethod("cluster", signature(x = "tNN", newdata = "matrix"),
  function(x, newdata, verbose = FALSE) {
    ## get a reference to the environment
    tnn_d <- x@tnn_d

    tnn_d$last <- character(nrow(newdata))

    for (i in 1:nrow(newdata)) {
      nd <- newdata[i, , drop = FALSE]
      if (verbose && i %% 100 == 0)
        cat("Added", i, "observations - ",
          nclusters(x), "clusters.\n")

      ## cluster is NA for rows with all NAs
      if (all(is.na(nd))) {
        tnn_d$last[i] <- as.character(NA)
        next
      }

      ## fade cluster structure?
      if (x@lambda > 0)
        tnn_d$counts <- tnn_d$counts * x@lambda_factor

      ## first cluster
      if (nclusters(x) < 1) {
        sel <- "1"
        rownames(nd) <- sel
        tnn_d$centers <- nd
        tnn_d$counts[sel] <- 1
        ## initialize variable threshold
        tnn_d$var_thresholds[sel] <- x@threshold

      } else{
        ## find a matching state
        #sel <- find_clusters(x, nd, match_cluster="exact")

        ### all with inside<=0 are matches
        inside <- dist(nd, tnn_d$centers,
          method = x@distFun) - tnn_d$var_thresholds
        names(inside) <- rownames(tnn_d$centers)

        ## find all matches
        matches <- names(inside)[which(inside < 0)]
        if (length(matches) == 0) {
          sel <- NA
        } else if (length(matches) == 1) {
          sel <- matches
        } else
          sel <- matches[which.min(inside[matches])]


        ## NA means no match -> create a new node
        if (is.na(sel)) {
          ## New node
          ## get new node name (highest node
          ## number is last entry in count)
          sel <- as.character(max(suppressWarnings(as.integer(
            names(tnn_d$counts)
          )), na.rm = TRUE) + 1L)

          rownames(nd) <- sel
          tnn_d$centers <- rbind(tnn_d$centers, nd)
          tnn_d$counts[sel] <- 1
          ## initialize threshold
          tnn_d$var_thresholds[sel] <- x@threshold

        } else{
          ## assign observation to existing node

          ## update center (if we use centroids)
          if (x@centroids) {
            ## try moving first
            nnas <- !is.na(nd)
            new_center <- tnn_d$centers[sel, ]
            new_center[nnas] <-
              (new_center[nnas] * tnn_d$counts[sel] +  nd[nnas]) / (tnn_d$counts[sel] +
                  1)

            ## replace NAs with the new data
            nas <- is.na(new_center)
            if (any(nas))
              new_center[nas] <- nd[nas]

            ## check if move is legal (does not enter
            ## another cluster's threshold)
            if (length(matches) < 2) {
              tnn_d$centers[sel, ] <- new_center
            } else{
              violation <- dist(rbind(new_center),
                tnn_d$centers[matches, ],
                method = x@distFun) - tnn_d$var_thresholds[matches]


              if (sum(violation < 0) < 2) {
                tnn_d$centers[sel, ] <- new_center
              }

            }

          }

          ## update counts
          tnn_d$counts[sel] <- tnn_d$counts[sel] + 1
        }
      }

      tnn_d$last[i] <- sel
    }


    if (verbose)
      cat ("Done -", nclusters(x), "clusters.\n")

    invisible(x)

  })
