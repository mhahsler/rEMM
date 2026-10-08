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


## predict next n states using P^n
#' Predict a Future State
#'
#' @name predict
#' @rdname predict
#' @aliases predict
#' @aliases predict,TRACDS-method
#' @description Predict a state or the probability distribution over states in \eqn{n}
#' time steps.
#' @param object an \code{"EMM"}/\code{"TRACDS"} object.
#' @param current_state use a specified current state.
#'     If \code{NULL}, the EMM's current state is used.
#' @param n number of time steps.
#' @param probabilities if \code{TRUE},
#'     instead of the predicted state, the probability distribution is returned.
#' @param randomized if \code{TRUE}, the predicted state is choosen
#'     randomly with a selection probability proportional to its transition
#'     probability
#' @param prior add one to each transition count. This is equal
#'       to starting with a uniform prior for the transition count distribution,
#'       i.e. initially all transitions are equally likely. It also prevents the
#'       product of probabilities to be zero if a transition was never observed.
#' @details Prediction is done using \eqn{A^n} where \eqn{A} is the transition
#' probability matrix maintained by the EMM.
#' Random tie-breaking is used.
#' @return The name of the predicted state or a vector with the probability
#'     distribution over all states.
#' @seealso \code{\link{transition_matrix}}
#' @examples data("EMMTraffic")
#' emm <- EMM(measure="eJaccard", threshold=0.2)
#' emm <- build(emm, EMMTraffic)
#'
#' #plot(emm) ## plot graph
#'
#' ## Predict state starting an state 1 after 1, 2 and 100 time intervals
#' ## Note, state 7 is an absorbing state.
#' predict(emm, n=1, current_state="1")
#' predict(emm, n=2, current_state="1")
#' predict(emm, n=100, current_state="1")
#'
#' ## Get probability distribution
#' predict(emm, n=2, current_state="1", probabilities = TRUE)
#' @keywords models
setMethod("predict", signature(object = "TRACDS"),
  function(object,
    current_state = NULL,
    n = 1,
    probabilities = FALSE,
    randomized = FALSE,
    prior = FALSE) {
    ## probabilistic max with random tie breaking
    .prob_max <- function(x) {
      m <- which(x == max(x))
      if (length(m) > 1)
        m <- sample(m, 1)
      m
    }

    ## randomized
    .randomized <- function(x)
      sample((1:length(x))[x > 0], 1, prob = x[x > 0])



    if (is.null(current_state))
      current_state <- current_state(object)
    else
      current_state <- as.character(current_state)

    current_state_i <- which(states(object) == current_state)

    ## check is state exists!
    if (!is.element(current_state, states(object)))
      stop("State does not exist")


    P <- transition_matrix(object, prior = prior)
    step <- P
    ## calculate P^n
    if (n > 1)
      for (i in 1:(n - 1))
        P <- P %*% step

    prob <- P[current_state_i, ]

    ## create result
    if (probabilities)
      return(prob)
    if (randomized)
      return(states(object)[.randomized(prob)])

    return(states(object)[.prob_max(prob)])
  })
