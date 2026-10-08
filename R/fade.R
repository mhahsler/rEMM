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


## build uses its own implementation of fade! See build.R

.fade <- function(x, t = 1, lambda = NULL) {
  if (is.null(lambda))
    lambda_factor <- x@lambda_factor
  else
    lambda_factor <- 2 ^ (-lambda)

  ## fade counts (tNN)
  x@tnn_d$counts <- x@tnn_d$counts * lambda_factor ^ t

  ## fade transition counts (TRACDS)
  x@tracds_d$mm <- smc_fade(x@tracds_d$mm, lambda_factor ^ t)

  invisible(x)
}


setMethod("fade", signature(x = "EMM", t = "numeric", lambda = "missing"),
  function(x, t, lambda)
    .fade(x, t))

setMethod("fade", signature(x = "EMM", t = "missing", lambda = "missing"),
  function(x, t, lambda)
    .fade(x, t = 1))

#' Fading Cluster Structure and EMM Layer
#'
#' @name fade
#' @rdname fade
#' @aliases fade
#' @aliases fade,EMM,numeric,numeric-method
#' @aliases fade,EMM,missing,numeric-method
#' @aliases fade,EMM,missing,missing-method
#' @aliases fade,EMM,numeric,missing-method
#' @description Reduces the weight of old observations in the data stream.
#' \code{build} has a learning rate parameter
#' \code{lambda}. If this parameter is set, \code{build} automatically
#' fades all counts before a new data point is added. The second
#' mechanism is to explicitly call the function~\code{fade} whenever
#' fading is needed. This has the advantage that the overhead of manipulating
#' all counts in the EMM can be reduced and that fading can be used in a more
#' flexible manner. For example, if the data points are arriving at an irregular
#' rate, \code{fade} could be called at regular time intervals
#' (e.g., every second).
#' @usage fade(x, t, lambda)
#' @param x an object of class \code{"EMM"}. Note that this
#'   function will change \code{x}.
#' @param t number of time intervals (if missing 1 is used)
#' @param lambda learning rate. If \code{lambda} is missing,
#' 	the learning rate specified for the EMM is used.
#' @details Old data points are faded by using a weight.
#' We define the weight
#' for data that is \eqn{t} timesteps in the past by the following strictly
#' decreasing function:
#' \deqn{w_t = 2^{-\lambda t}}{w_t = 2^(-lambda t)}
#'
#' Since the weight is multiplicative, it can be applied iteratively by
#' multiplying at each time step all counts by \eqn{2^{-\lambda}}{2^-lambda}.
#' For the clustering algorithm the weight of the clusters (number of data
#' points assigned to the cluster) is faded. For the EMM the initial count vector
#' and all transition counts are faded.
#' @return Returns a reference to the changed object \code{x}.
#' @seealso \code{\linkS4class{EMM}} and \code{\link{build}}
#' @examples data("EMMTraffic")
#'
#' ## For the example we use a very high learning rate
#' ## this calls fade after each new data point
#' emm_l <- EMM(measure="eJaccard", threshold=0.2, lambda = 1)
#' build(emm_l, EMMTraffic)
#'
#' ## build a regular EMM for comparison
#' emm <- EMM(measure="eJaccard", threshold=0.2)
#' build(emm, EMMTraffic)
#'
#' ## compare the transition matrix
#' transition_matrix(emm)
#' transition_matrix(emm_l)
#'
#' ## compare graphs
#' op <- par(mfrow = c(1, 2), pty = "m")
#' plot(emm, main = "regular EMM")
#' plot(emm_l, main = "EMM with high learning rate")
#' par(op)
#' @keywords manip
setMethod("fade", signature(x = "EMM", t = "numeric", lambda = "numeric"),
  function(x, t, lambda)
    .fade(x, t, lambda))

setMethod("fade", signature(x = "EMM", t = "missing", lambda = "numeric"),
  function(x, t, lambda)
    .fade(x, , lambda))
