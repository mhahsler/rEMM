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

## update for TRACDS for cluster assignments

### alias update
#' Update a TRACDS temporal structure with new state assignements
#'
#' @name update
#' @rdname update
#' @aliases update
#' @aliases update,TRACDS-method
#' @aliases reset
#' @aliases reset,TRACDS-method
#' @aliases compact
#' @aliases compact,TRACDS-method
#' @description Add a sequence of new state assignments to a TRACDS object.
#' @param x,object a \code{TRACDS} object. Note that this function changes the original object!
#' @param newdata a vector with a state assignemnt sequence (typically
#'   produced by clustering).
#' @param verbose logical; verbose output?
#' @param ... further arguments.
#' @details \code{update()}
#'     adds a new state assignemnt sequenc to the TRACDS object by increasing the
#'     transition counts and, if needed, creating new states.
#'
#'     \code{reset()} resets the current state to \code{NA} for reading in a
#'     new sequence. An \code{NA} in \code{newdata}
#'     also resets the current state.
#'
#'     \code{compact()} reduces the size (memory) used to store the temporal
#'     transition matrix.
#' @return A reference to the changed TRACDS object with the data added.
#' Note: EMM objects store all variable data in an environment which
#' enables us to update partial data without copying the whole object. Assignment
#' will not create a copy! Use the provided method \code{copy()}.
#' @seealso Class \code{\linkS4class{TRACDS}},
#' 	\code{\link{fade}}.
#' @examples ## create an empty TRACDS object
#' tracds <- TRACDS()
#' tracds
#'
#' ## update with an cluster assignment sequence
#' update(tracds, c(1,2,5,5,2))
#' tracds
#'
#' plot(tracds)
#' @keywords models
setMethod("update", signature(object = "TRACDS"),
  function(object, newdata, verbose = FALSE, ...) {
    if (verbose)
      cat("Update for", length(newdata),
        "assignments", "\n")

    x <- object

    tracds_d <- x@tracds_d  ### get the environment

    counts <- tracds_d$mm@counts ### get matrix for performance
    ### otherwise R copies the matrix
    ### for each update

    ## inline function to increase performance
    .addState <- function(name) {
      ## expand?
      if (tracds_d$mm@top < 1) {
        old_size <- nstates(x)

        new_size <- old_size * 2L

        if (verbose)
          cat("Resizing matrix from", old_size , "to",
            new_size, "\n")

        new_counts <- matrix(0, ncol = new_size, nrow = new_size)
        #new_counts[1:old_size, 1:old_size] <- tracds_d$mm@counts
        #tracds_d$mm@counts <- new_counts
        new_counts[1:old_size, 1:old_size] <- counts
        counts <<- new_counts

        new_initial_counts <- numeric(new_size)
        new_initial_counts[1:old_size] <- tracds_d$mm@initial_counts
        names(new_initial_counts)[1:old_size] <-
          names(tracds_d$mm@initial_counts)
        tracds_d$mm@initial_counts <- new_initial_counts

        new_unused <- new_size:1
        new_unused[(old_size + 1):length(new_unused)] <-
          tracds_d$mm@unused
        tracds_d$mm@unused <- new_unused

        tracds_d$mm@top <- old_size + tracds_d$mm@top
      }

      ## add node
      pos <- tracds_d$mm@unused[tracds_d$mm@top]
      tracds_d$mm@unused[tracds_d$mm@top] <- NA
      tracds_d$mm@top <- tracds_d$mm@top - 1L
      names(tracds_d$mm@initial_counts)[pos] <- name

      tracds_d$mm@initial_counts[pos] <- 0

      pos
    }

    ## use storage positions because removed states can leave gaps
    pos_current <- match(current_state(x), names(tracds_d$mm@initial_counts))
    if (is.na(current_state(x)) || is.na(pos_current))
      pos_current <- integer(0)
    i <- 1

    ## iterate over cluster assignments in newdata
    for (sel in newdata) {
      if (verbose && !(i %% 100))
        cat("Processing assignment", i, "\n")
      i <- i + 1

      ## cluster returns NA if we start a new sequence.
      if (is.na(sel)) {
        pos_current <- numeric(0)
        next
      }

      ## fade TRACDS structure?
      ### FIXME: counts!!!
      if (x@lambda > 0) {
        counts <- counts * x@lambda_factor
        tracds_d$mm@initial_counts <-
          tracds_d$mm@initial_counts *  x@lambda_factor
        #    tracds_d$mm <- smc_fade(tracds_d$mm,
        #	x@lambda_factor)
      }


      ## state exists?
      pos_new <- match(sel, names(tracds_d$mm@initial_counts))

      ## no: create state
      if (is.na(pos_new))
        pos_new <- .addState(sel)

      ## add transition
      ## no current state?
      if (!length(pos_current)) {
        tracds_d$mm@initial_counts[pos_new] <-
          tracds_d$mm@initial_counts[pos_new] + 1
      } else{
        ## tracds_d$mm@counts[pos_current, pos_new] <- tracds_d$mm@counts[pos_current, pos_new] + 1
        counts[pos_current, pos_new] <-
          counts[pos_current, pos_new] + 1
      }

      ## update current_state
      pos_current <- pos_new
    }

    ## save the last state as current
    tracds_d$current_state <- sel

    ### return counts to object
    tracds_d$mm@counts <- counts

    if (verbose)
      cat("Update done.", "\n")

    invisible(x)
  })
