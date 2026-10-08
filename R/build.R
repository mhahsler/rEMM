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


## build for EMM


## make  newdata a matrix (with a single row)
setMethod("build", signature(x = "EMM", newdata = "numeric"),
  function(x, newdata, verbose = FALSE)
    build(x,
      as.matrix(rbind(newdata), verbose)))

setMethod("build", signature(x = "EMM", newdata = "data.frame"),
  function(x, newdata, verbose = FALSE)
    build(x, as.matrix(newdata),
      verbose))

#' Building an EMM using New Data
#'
#' @name build
#' @rdname build
#' @aliases build
#' @aliases build,EMM,data.frame-method
#' @aliases build,EMM,matrix-method
#' @aliases build,EMM,numeric-method
#' @description Add new data to an EMM.
#' @usage build(x, newdata, ...)
#' @param x an \code{EMM} object. Note that the function will change the original EMM!
#' @param newdata a vector (one observation), or a matrix or data.frame
#'     (each row is an observation)
#' @param ... further arguments. If \code{newdata} is a matrix
#'   or a data.frame then \code{verbose = TRUE} can be used to monitor
#'   the progress of
#'   building the model.
#' @details \code{build()} performs clustering and also updates the TRACDS temporal
#'     layer.
#'
#'     \code{NA}s are handled in the data by using only the other
#' 	dimensions if the data for dissimilarity computation
#' 	(see package \pkg{proxy}).
#' @return A reference to the changed EMM object with the data added.
#' Note: EMM objects store all variable data in an environment which
#' enables us to update partial data without copying the whole object. Assignment
#' will not create a copy! Use the provided method \code{copy()}.
#' @seealso Class \code{\linkS4class{TRACDS}},
#' 	\code{\link{fade}} and \code{\link[proxy]{dist}}
#' 	in \pkg{proxy}.
#' @examples ## load EMMTraffic data
#' data("EMMTraffic")
#' EMMTraffic
#'
#' ## create EMM
#' emm <- EMM(measure="eJaccard", threshold=0.2)
#'
#' ## build model using EMMTraffic data (note that the EMM object is
#' ## changed without assignment!)
#' build(emm, EMMTraffic)
#' ## same as: emm <- build(emm, EMMTraffic)
#'
#' size(emm)
#' plot(emm)
#'
#' ## emm2 <- emm does not create a copy (just a reference)
#' ## a "deep" copy is created using copy()
#' emm2<- copy(emm)
#'
#' ## convert the emm into a graph
#' as.igraph(emm)
#' @keywords models
setMethod("build", signature(x = "EMM", newdata = "matrix"),
  function(x, newdata, verbose = FALSE) {
    if (verbose)
      cat("Adding", nrow(newdata) , "observations.", "\n")

    ## cluster all the data (the variable data is in an
    ## environment, so there is no need for x <- cluster(x, newdata))
    cluster(x, newdata, verbose = verbose)

    ## now update TRACDS (iterate over cluster assignments in last)
    update(x, last_clustering(x), verbose = verbose)

    invisible(x)
  })
