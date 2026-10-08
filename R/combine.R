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


#' Combining EMM Objects
#'
#' @name combine
#' @rdname combine
#' @aliases c
#' @aliases c,EMM-method
#' @description Combines two or more EMMs into a single object.
#' @param x first \code{EMM} object. Note that this object will be changed
#'   by the function if \code{copy=FALSE}!
#' @param ... further objects of the same class as \code{x} to be combined.
#' @param copy a logical. Copy \code{x} first? Otherwise x will be changed!
#' @param recursive a logical. If \code{recursive=TRUE},
#'     the function recursively
#'     descends through lists combining all their elements into a
#'     vector.
#' @return Returns invisibly an object of the same class as \code{EMM}.
#' @seealso \code{\link{EMM-class}},
#' @examples data("16S")
#'
#' ## create two EMMs for different data
#' emm1 <- EMM("Kullback", threshold=0.1, data=Mollicutes16S+1)
#' emm2 <- EMM("Kullback", threshold=0.1, data=Alphaproteobacteria16S+1)
#'
#' ## combine the two EMMs
#' emm12 <- c(emm1, emm2)
#' ## this is the same as:
#' ## emm12 <- copy(emm1)
#' ## c(emm12, emm2, copy=FALSE)
#'
#' ## recluster states so similar states in the to EMMs will be merged
#' emm12r <- recluster_tNN(emm12)
#'
#' op <- par(mfrow = c(1, 2), pty = "s")
#' plot(emm12, main="Two EMMs")
#' plot(emm12r, main="Two EMMs (reclustered)")
#' par(op)
#' @keywords manip
setMethod("c", signature(x = "EMM"),
  function(x,
    ...,
    copy = TRUE,
    recursive = FALSE) {
    args <- list(...)

    if (copy)
      x <- copy(x)

    if (recursive)
      args <- unlist(args)
    for (y in args) {
      if (!is(y, "EMM"))
        stop("can combine EMM only")


      ## combine tracds
      nx <- smc_size(x@tracds_d$mm)
      ny <- smc_size(y@tracds_d$mm)
      n <- nx + ny

      new_labels <- as.character(1:n)
      #new_labels <- c(clusters(x), paste("A", clusters(y)))

      x@tracds_d$mm <- new(
        "SimpleMC",
        unused = rep(as.integer(NA), n),
        top = 0L,
        counts = structure(rbind(
          cbind(
            smc_countMatrix(x@tracds_d$mm),
            matrix(0, ncol = ny, nrow = nx)
          ),
          cbind(
            matrix(0, ncol = nx, nrow = ny),
            smc_countMatrix(y@tracds_d$mm)
          )
        ),
          dimnames = list(new_labels, new_labels)),

        initial_counts = structure(c(
          smc_initialCounts(x@tracds_d$mm),
          smc_initialCounts(y@tracds_d$mm)
        ),
          names = new_labels)
      )

      x@tracds_d$current_state <- NA

      ## combine tNN
      x@tnn_d$centers <- structure(rbind(x@tnn_d$centers, y@tnn_d$centers),
        dimnames = list(new_labels, colnames(x@tnn_d$centers)))

      x@tnn_d$counts <- structure(c(x@tnn_d$counts, y@tnn_d$counts),
        names = new_labels)

      x@tnn_d$var_thresholds <- structure(c(x@tnn_d$var_thresholds,
        y@tnn_d$var_thresholds),
        names = new_labels)

      x@tnn_d$last <- NA
    }


    invisible(x)
  })
