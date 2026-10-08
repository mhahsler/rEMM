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


setMethod("transition", signature(x = "TRACDS",
  from = "matrix", to = "missing"),
  function(x,
    from,
    to,
    type = c("probability", "counts", "log_odds"),
    prior = TRUE) {
    to <- from[, 2]
    from <- from[, 1]

    transition(x, from, to, type, prior)
  })

setMethod("transition", signature(x = "TRACDS",
  from = "data.frame", to = "missing"),
  function(x,
    from,
    to,
    type = c("probability", "counts", "log_odds"),
    prior = TRUE) {
    to <- from[, 2]
    from <- from[, 1]

    transition(x, from, to, type, prior)
  })

#' Access Transition Probabilities/Counts in an EMM
#'
#' @name transition
#' @rdname transition
#' @aliases transition
#' @aliases transition,TRACDS,character,character-method
#' @aliases transition,TRACDS,matrix,missing-method
#' @aliases transition,TRACDS,data.frame,missing-method
#' @aliases transition_matrix
#' @aliases transition_matrix,TRACDS-method
#' @aliases initial_transition
#' @aliases initial_transition,TRACDS-method
#' @description Calculates individual transition probabilities/counts
#' or a complete transition matrix
#' for an EMM (which contains \code{"TRACDS"}).
#' @param x an object of class \code{"EMM"}/\code{"TRACDS"}.
#' @param from,to Names a states. If \code{to} is missing,
#'   \code{from} has
#'   to contain a matrix with two columns (a from column and a
#'   to column as returned by \code{transitions}).
#' @param type What should be calculated?
#' @param prior add one to each transition count. This is equal
#'       to starting with a uniform prior for the transition count distribution,
#'       i.e., initially all transitions are equally likely.
#' @details Log odds are calculated as \eqn{ln(a/(1/n))} where \eqn{a} is the probability
#' of the transition and \eqn{n} is the number of states in the EMM.  \eqn{1/n} is
#' the probability of a transition under the null model which assumes that the
#' transition probability from each state to each other state (including staying
#' in the same state) is the same, i.e., the null model has a transition matrix
#' with all entries equal to \eqn{1/n}.
#' @return A scalar (for \code{transition}), a square matrix
#'     (for \code{transition_matrix}) or a vector (for \code{initial_transition}).
#' @seealso \code{\linkS4class{EMM}} which contains
#' \code{\linkS4class{TRACDS}}
#' @examples data("EMMTraffic")
#' emm <- EMM(measure="eJaccard", threshold=0.2)
#' emm <- build(emm, EMMTraffic)
#'
#' ## get transition matrix
#' transition_matrix(emm, type="count", prior=FALSE)
#' transition_matrix(emm, type="count")
#' transition_matrix(emm, prior=FALSE)
#' transition_matrix(emm)
#'
#' ## get initial state probabilities
#' initial_transition(emm)
#'
#' ## access individual transition probability (state 1 -> 2)
#' transition(emm, "1","2")
#'
#' ## get counts for all existing transitions
#' tr <- transitions(emm)
#' tr
#' cbind(as.data.frame(tr), counts=transition(emm, tr, type="counts"))
#' @keywords models
setMethod("transition", signature(x = "TRACDS", from = "character", to =
    "character"), function(x,
      from,
      to,
      type = c("probability",
        "counts", "log_odds"),
      prior = TRUE) {
      type <- match.arg(type)

      if (length(from) != length(to))
        stop("vectors from and to are not of the same length!")

      ### deal with empty from/to
      if (length(from) < 1)
        return(numeric(0))

      tm <- transition_matrix(x, type, prior)

      from <- match(from, states(x))
      to <- match(to, states(x))
      res <-
        sapply(
          1:length(from),
          FUN = function(i)
            tm[from[i], to[i]]
        )

      ## handle missing states (NA)
      res[is.na(res)] <- 0
      res
    })



#' @rdname transition
setMethod("transition_matrix", signature(x = "TRACDS"),
  function(x,
    type = c("probability", "counts", "log_odds"),
    prior = TRUE) {
    type <- match.arg(type)

    ## get transition count matrix
    m <- smc_countMatrix(x@tracds_d$mm)

    if (prior)
      m <- m + 1

    if (type == "counts")
      return(m)

    rs <- rowSums(m)
    prob <- m / rs

    ## we have to handle absorbing states here (row sum is 0)
    absorbing <- which(rs == 0)
    prob[absorbing, ] <- 0
    for (i in absorbing)
      prob[i, i] <- 1

    switch(type,
      probability = prob,
      log_odds = log(prob * size(x)))
  })


#' @rdname transition
setMethod("initial_transition", signature(x = "TRACDS"),
  function(x,
    type = c("probability", "counts", "log_odds"),
    prior = TRUE) {
    type <- match.arg(type)

    ic <- smc_initialCounts(x@tracds_d$mm)
    if (prior)
      ic <- ic + 1

    switch(
      type,
      probability = ic / sum(ic),
      counts = ic,
      log_odds = log(ic / sum(ic) * size(x))
    )
  })


setMethod("transition_table", signature(x = "EMM", newdata = "numeric"),
  function(x,
    newdata,
    type = c("probability", "counts", "log_odds"),
    match_cluster = "exact",
    prior = TRUE,
    initial_transition = FALSE)
    transition_table(
      x,
      as.matrix(rbind(newdata)),
      type,
      match_cluster,
      prior,
      initial_transition
    ))

setMethod("transition_table", signature(x = "EMM", newdata = "data.frame"),
  function(x,
    newdata,
    type = c("probability", "counts", "log_odds"),
    match_cluster = "exact",
    prior = TRUE,
    initial_transition = FALSE)
    transition_table(
      x,
      as.matrix(newdata),
      type,
      match_cluster,
      prior,
      initial_transition
    ))

#' Extract a Transition Table for a New Sequence Given an EMM
#'
#' @name transition_table
#' @rdname transition_table
#' @aliases transition_table
#' @aliases transition_table,EMM,numeric-method
#' @aliases transition_table,EMM,data.frame-method
#' @aliases transition_table,EMM,matrix-method
#' @description Finds the state sequence of a new sequence in an EMM and returns a table
#' with the transition probabilities or counts.
#' @param x an \code{EMM} object.
#' @param newdata new sequence,
#' @param type the measure to return.
#' @param match_cluster do the new observations have to fall within
#'     the threshold of the cluster (\code{"exact"}) or is nearest neighbor
#'     used (\code{"nn"})?
#' @param prior add one to each transition count. This is equal
#'       to starting with a uniform prior for the transition count distribution,
#' 	i.e. initially all transitions are equally likely. It also prevents the
#' 	product of probabilities to be zero if a transition was never observed.
#' @param initial_transition include the initial transition
#' 	 in the table?
#' @return A data.frame with three columns (from state, to state and the
#'     transition probability/count.)
#' @seealso \code{\link{transition}} to access transition probabilities
#' and \code{\link{find_clusters}} for assigning observations to states/clusters.
#' @examples data("EMMsim")
#'
#' emm <- EMM(threshold=.5)
#' emm <- build(emm, EMMsim_train)
#'
#' head(transition_table(emm, EMMsim_test))
#' head(transition_table(emm, EMMsim_test, type ="prob", initial_transition=TRUE))
#' @keywords models
setMethod("transition_table", signature(x = "EMM", newdata = "matrix"),
  function(x,
    newdata,
    type = c("probability", "counts", "log_odds"),
    match_cluster = "exact",
    prior = TRUE,
    initial_transition = FALSE) {
    type <- match.arg(type)

    ## make sure  newdata is a matrix (maybe a single row)
    if (!is.matrix(newdata))
      newdata <- as.matrix(rbind(newdata))
    n <- nrow(newdata)

    ## empty EMM or single state?
    if (n < 2) {
      df <- data.frame(from = NA, to = NA, val = NA)
      names(df)[3] <- type
      return(df)
    }

    ## get sequence
    ssequence <-
      find_clusters(x, newdata, match_cluster = match_cluster,
        dist = FALSE)
    from <- ssequence[1:(n - 1)]
    to <- ssequence[2:n]

    ## get values
    res <- transition(x, from, to, type = type,
      prior = prior)

    if (initial_transition) {
      from <- c(NA, from)
      to <- c(ssequence[1], to)
      res <- c(initial_transition(x, type = type,
        prior = prior)[ssequence[1]],
        res)
    }

    df <-
      data.frame(
        from = from,
        to = to,
        val = res,
        stringsAsFactors = FALSE
      )
    names(df)[3] <- type
    return(df)
  })
