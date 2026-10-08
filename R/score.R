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


### exponential
#.simil_weight <- function(d, th) {
#  w <- .5^(d/th - 1)
#  w[d<=th] <-1
#  w
#}

### use sigmoid curve instead
.simil_weight <- function(d, th) {
  w <- 1 - plogis(d / th, 1.5, .2)
  #w <- 1- 1/(1+exp(-(d-1.5)/.2))
  w
}

## linear
#.simil_weight <- function(d, th) {
#  d <- d/th
#  w <- 2-d
#  w[d<=1] <- 1
#  w[d>2] <- 0
#  w
#}

## does newdata come from the EMM?
setMethod("score", signature(x = "EMM", newdata = "numeric"),
  function(x,
    newdata,
    method = NULL,
    match_cluster = "exact",
    random = FALSE,
    prior = TRUE,
    normalize = TRUE,
    initial_transition = FALSE,
    threshold = NA)
    score(
      x,
      as.matrix(rbind(newdata)),
      method,
      match_cluster,
      random,
      prior,
      normalize,
      initial_transition,
      threshold
    ))

setMethod("score", signature(x = "EMM", newdata = "data.frame"),
  function(x,
    newdata,
    method = NULL,
    match_cluster = "exact",
    random = FALSE,
    prior = TRUE,
    normalize = TRUE,
    initial_transition = FALSE,
    threshold = NA)
    score(
      x,
      as.matrix(newdata),
      method,
      match_cluster,
      random,
      prior,
      normalize,
      initial_transition,
      threshold
    ))

#' Score a New Sequence Given an EMM
#'
#' @name score
#' @rdname score
#' @aliases score
#' @aliases score,EMM,numeric-method
#' @aliases score,EMM,data.frame-method
#' @aliases score,EMM,matrix-method
#' @aliases score,EMM,EMM-method
#' @description Calculates a score of how likely it is that a new sequence was generated
#'   by the same process as the sequences used to build the EMM.
#' @param x an \code{EMM} object.
#' @param newdata sequence or another \code{EMM} object to score.
#' @param method method to calculate the score (see details)
#' @param match_cluster do the new observations have to fall within
#'                         the threshold of the cluster (\code{"exact"}) or is nearest neighbor
#'                         (\code{"nn"}) or weighted nearest neighbor (\code{weighted}) used?
#'                         If \code{match_cluster} is a number n then observations
#'                         need to fall within n times the clustering threshold of the cluster.
#' @param random logical; should the order of newdata be randomized? Can be used to compare the score with the
#'                         actual score.
#' @param prior logical; add one to each transition count. This is equal
#'                    to start with a count of one  for each transition, i.e. initially all
#'                    transitions are equally likely. It prevents the product
#'                    of probabilities to be zero if a transition was never observed.
#' @param normalize logical; normalize the score by the length of the sequence.
#' @param initial_transition logical; include the initial transition
#'                              in the computation?
#' @param threshold minimum count threshold used by supported transitions and supported states.
#' @details The scores for a new sequence \eqn{x} of length \eqn{l} can be computed
#'   by the following methods. For \code{match_cluster="exact"} or \code{"nn"}:
#'
#'     \describe{
#'       \item{"product"}{
#'         Product of transition probabilities along the path of \eqn{x} in the
#'         model. A single missing transition (transition probability of zero)
#'         will result in
#'         a score of 0. Use \code{prior} to avoid this.
#'         \deqn{S_\mathrm{product} = \sqrt[l-1]{\prod_{i=1}^{l-1}{a_{s(i),s(i+1)}}}}{
#'           S_product = prod(a_s(i),s(i+1))^(1/(l-1))}
#'
#'         where \eqn{a_{s(i),s(j)}}{a_s(i),s(j)} is the transition probability
#'         between the state representing positions \eqn{i} and \eqn{j} in the sequence.
#'       }
#'
#'       \item{"sum"}{
#'         Average of transition probabilities along the path of \eqn{x} in the
#'         model.
#'         \deqn{S_\mathrm{sum} = \frac{1}{l-1} \sum_{i=1}^{l-1}{a_{s(i),s(i+1)}}}{
#'           S_sum = 1/(l-1) sum(a_s(i),s(i+1))}
#'       }
#'       \item{"log_sum"}{
#'         Average of the log of the transition probabilities along the path of
#'         \eqn{x} in the model. The ranking of the scores is equivalent to
#'         the product of probabilities, however, the calculation is more reliable
#'         since the product of probabilities might become a very small number.
#'
#'         A single missing transition (transition probability of zero)
#'         will result in a score of neg. infinity.
#'         Use \code{prior} to avoid this.
#'
#'         \deqn{S_\mathrm{log\_sum} = \frac{1}{l-1} \sum_{i=1}^{l-1}{\mathrm{log}(a_{s(i),s(i+1)})}}{
#'           S_sum = 1/(l-1) sum(log(a_s(i),s(i+1)))}
#'       }
#'
#'
#'       \item{"supported_transitions"}{Fraction of transitions in the new sequence \eqn{x} supported (present) in the model after assigning each data point in \eqn{x} to a state in
#'                                      the model.
#'                                      \deqn{S_\mathrm{supported\_transitions} = \frac{1}{l-1} \sum_{i=1}^{l-1}{\mathrm{I}(a_{s(i),s(i+1)})}}{
#'                                        S_supported_transitions = 1/(l-1) sum(I(a_s(i),s(i+1)))}
#'       }
#'
#'
#'
#'       \item{"supported_states"}{Fraction of points in the new sequence \eqn{x}
#'                                 for which a state (cluster) exists in the model. \code{match_cluster}
#'                                 is always \code{"exact"} because for \code{"nn"} this measure would
#'                                 always give 1. Note that this measure ignores transition information.
#'
#'                                 If threshold is given, then only states with a count greater than the given threshold are counted as supported.
#'       }
#'
#'       \item{"sum_transitions"}{Sum of the counts on the edges in the model on the path of sequence \eqn{x} normalized by the total number of transition counts in the model.
#'                                \deqn{S_\mathrm{sum\_transitions} = \frac{1}{l-1} \sum_{i=1}^{l-1}c_{s(i),s(i+1)}}{
#'                                  S_sum_transitions = 1/(l-1) sum(c_s(i),s(i+1))}
#'
#'                                where \eqn{c_{s(i),s(i+1)}}{c_s(i),s(i+1)} is the transition count  between the state representing positions \eqn{i} and \eqn{j} in the sequence.
#'
#'
#'                                If threshold is given, then only transitions with a count greater than the given threshold are counted as supported.
#'       }
#'       \item{"likelihood", "log_likelihood"}{ The likelihood of the model given the new data is the
#'       unnormalized product score (product of transition probabilities).}
#'       \item{"log_loss"}{ The average log loss is defined as
#'                          \deqn{-sum(log2(a_s(i),s(i+1)))/(l-1)}
#'       It represents the average compression rate of the new sequence
#'                          given the model.
#'       }
#'       \item{"AIC"}{ Akaike Information Criterion corrected for finite sample size.
#'       \deqn{2k - 2log(L) 2k(k-1)/(n-k-1)}
#'       where \eqn{n=l-1} and \eqn{k} is the model complexity measured by the number of
#'                     non-zero entries in the transition matrix.
#'                     We use the likelihood of the model given by the proportion
#'                     of supported transitions. AIC can be used for model selection
#'                     where the smallest value indicates the preferred model.
#'       }
#'
#'     }
#'   where
#'   \eqn{x_i} represents the \eqn{i}-th data point in the new sequence,
#'   \eqn{a(i,j)} is the transition probability from state \eqn{i}
#'   to state \eqn{j} in the model,
#'   \eqn{s(i)} is the state the \eqn{i}-th data point (\eqn{x_i}) in
#'   the new sequence is assigned to.
#'   \eqn{\mathrm{I(v)}}{I(v)} is an indicator function which is 0 for \eqn{v=0} and 1 otherwise.
#'
#'
#'
#'   For \code{match_cluster="weighted"}:
#'   \describe{
#'     \item{"product"}{
#'       Weighted version of the product of probabilities. The weight is
#'       the  similarity between a new data point and the state in the model
#'       it is assigned to.
#'       \deqn{S_\mathrm{weighted\_product} = \sqrt[l-1]{\prod_{i=1}^{l-1}{\mathrm{simil}(x_i,s(i))\mathrm{simil}(x_i,s(i+1))  a_{s(i),s(i+1)}}}}{
#'         P_weighted_product = prod(simil(x_i,s(i))simil(x_i,s(i+1)) a_s(i),s(i+1))^(1/(l-1))}
#'     }
#'   \item{"sum"}{
#'     Weighted version of the sum of probabilities.
#'     \deqn{S_\mathrm{weighted\_sum} = \frac{1}{l-1} \sum_{i=1}^{l-1}{\mathrm{simil}(x_i,s(i))\mathrm{simil}(x_i,s(i+1))  a_{s(i),s(i+1)}}}{
#'       S_weighted_sum = 1/(l-1) sum(simil(x_i,s(i))simil(x_i,s(i+1))  a_s(i),s(i+1))}
#'   }
#'   \item{"log_sum"}{
#'     Weighted version of the sum of the log of probabilities.
#'     \deqn{S_\mathrm{weighted\_log\_sum} = \frac{1}{l-1} \sum_{i=1}^{l-1}{\mathrm{log}(\mathrm{simil}(x_i,s(i))\mathrm{simil}(x_i,s(i+1))  a_{s(i),s(i+1)})}}{
#'       S_sum = 1/(l-1) sum(simil(x_i,s(i))simil(x_i,s(i+1))  a_s(i),s(i+1))}
#'   }
#'
#'   \item{"supported_states"}{
#'     Same as \code{"supported_states"} but instead of counting the
#'     supported states, the similarity \eqn{\mathrm{simil}(x_i,s(i))}{simil(x_i,s(i))}
#'     is used as a weight. Threshold is not implemented.
#'   }
#' }
#'
#' where \eqn{\mathrm{simil}(\cdot)}{simil(.)} is a modified and normalized
#' similarity function given by
#' \eqn{\mathrm{simil}(x,s) =  1- \frac{1}{1+e^{-\frac{\mathrm{d}(x, s)/t -1.5}{.2}}}}{simil(x,s)=1-1/(1+exp(-(d(x,s)/t-1.5)/.2))}
#' where \eqn{d} is the distance measure and \eqn{t} is the threshold that
#'   was used to create the model.
#' @return A scalar score value.
#' @seealso \code{\link{transition}} to access transition probabilities
#'          and \code{\link{find_clusters}} for assigning observations to states/clusters.
#' @examples data("EMMsim")
#'
#' emm <- EMM(threshold = .2)
#' emm <- build(emm, EMMsim_train)
#'
#' # default is method "product". The score is much higher compared to a randomized order.
#' score(emm, EMMsim_test)
#' score(emm, EMMsim_test, random = TRUE)
#'
#'
#' ### create shuffled data (destroy temporal relationship)
#' ### and create noisy data
#' test_shuffled <- EMMsim_test[sample(1:nrow(EMMsim_test)), ]
#' test_noise <- jitter(EMMsim_test, amount = .3)
#'
#' ### helper for plotting
#' mybars <- function(...) {
#'   oldpar <- par(mar = c(5, 10, 4, 2))
#'   ss <- rbind(...)
#'   barplot(
#'     ss[, ncol(ss):1],
#'     xlim = c(-1, 4),
#'     beside = TRUE,
#'     horiz = TRUE,
#'     las = 2,
#'     legend.text = rownames(ss)
#'   )
#'   par(oldpar)
#' }
#'
#'
#' ### compare various scores
#' methods <- c(
#'   "product",
#'   "sum",
#'   "log_sum",
#'   "supported_states",
#'   "supported_transitions",
#'   "sum_transitions",
#'   "log_loss",
#'   "likelihood"
#' )
#'
#' ### default is exact matching
#' clean <-
#'   sapply(
#'     methods,
#'     FUN = function(m)
#'       score(emm, EMMsim_test, method = m)
#'   )
#'
#' shuffled <-
#'   sapply(
#'     methods,
#'     FUN = function(m)
#'       score(emm, test_shuffled, method = m)
#'   )
#'
#' noise <-
#'   sapply(
#'     methods,
#'     FUN = function(m)
#'       score(emm, test_noise, method = m)
#'   )
#'
#' mybars(shuffled, noise, clean)
#'
#' ### weighted matching is better for noisy data
#' clean <-
#'   sapply(
#'     methods,
#'     FUN = function(m)
#'       score(emm, EMMsim_test, method = m,
#'         match_cluster = "weighted")
#'   )
#'
#' shuffled <-
#'   sapply(
#'     methods,
#'     FUN = function(m)
#'       score(emm, test_shuffled, method = m,
#'         match_cluster = "weighted")
#'   )
#'
#' noise <-
#'   sapply(
#'     methods,
#'     FUN = function(m)
#'       score(emm, test_noise, method = m,
#'         match_cluster = "weighted")
#'   )
#'
#' mybars(shuffled, noise, clean)
#' @keywords models
setMethod("score", signature(x = "EMM", newdata = "matrix"),
  function(x,
    newdata,
    method = c(
      "product",
      "log_sum",
      "sum",
      "log_odds",
      "supported_transitions",
      "supported_states",
      "sum_transitions",
      "log_loss",
      "likelihood",
      "log_likelihood",
      "AIC"
    ),
    match_cluster = "exact",
    random = FALSE,
    prior = TRUE,
    normalize = TRUE,
    initial_transition = FALSE,
    threshold = NA) {
    method <- match.arg(method)

    if (!is.numeric(match_cluster))
      match_cluster <-
        match.arg(match_cluster, c("exact", "nn", "weighted"))

    ### deal with empty models
    if (nclusters(x) < 1)
      return(if (method == "log_odds")
        - Inf
        else
          0)

    if (random) {
      newdata <- newdata[sample(seq(nrow(newdata))), , drop = FALSE]
    }

    if (method == "supported_transitions") {
      ###if(prior) warning("prior has no effect on supported transitions!")
      prior <- FALSE
    }

    ### FIXME: Don't know about log_odds!
    if (method == "log_odds") {
      log_odds <- transition_table(x, newdata, type = "log_odds",
        match_cluster, prior,
        initial_transition)[, 3]
      return(sum(log_odds, na.rm = TRUE))
    }

    ### calc: tt with  count and (weighted) prob
    ###       state_weight ... (weighted) cluster membership
    ###       states ... matching states

    if (match_cluster != "weighted") {
      tt <- transition_table(
        x,
        newdata,
        type = "probability",
        match_cluster = match_cluster,
        prior = prior,
        initial_transition = initial_transition
      )
      tt[["count"]] <-
        transition(x, tt, type = "count", prior = prior)

      ### clusters
      states <- c(tt[, "from"], tail(tt[, "to"], n = 1))
      state_weight <- as.integer(!is.na(states))

    } else{
      tt <- transition_table(
        x,
        newdata,
        type = "probability",
        match_cluster = "nn",
        prior = prior,
        initial_transition = initial_transition
      )
      tt[["count"]] <-
        transition(x, tt, type = "count", prior = prior)

      states <- c(tt[, "from"], tail(tt[, "to"], n = 1))

      n <- length(states)
      state_weight <- numeric(n)
      for (i in 1:n) {
        state_weight[i] <- as.numeric(.simil_weight(
          dist(newdata[i, , drop = FALSE],
            cluster_centers(x)[states[i], , drop = FALSE],
            measure = x@measure),
          #x@threshold
          x@tnn_d$var_thresholds[states[i]]
        ))
      }

      ### weight is the product of source and target weight
      weight <- state_weight[-n] * state_weight[-1]
      tt[, "probability"] <- weight * tt[, "probability"]
      tt[, "count"] <- weight * tt[, "count"]
    }

    ### remove states and transitions with count < threshold
    if (!is.na(threshold)) {
      state_weight[cluster_counts(x)[states] < threshold] <- NA
      rem <- tt[, "count"] < threshold
      tt[rem, "probability"] <- NA
      tt[rem, "count"] <- NA

    }

    if (method == "supported_states") {
      if (normalize)
        return(sum(state_weight, na.rm = TRUE) / length(state_weight))
      else
        return(sum(state_weight, na.rm = TRUE))
    }

    if (method == "supported_transitions") {
      ###if(prior) warning("prior has no effect on supported transitions!")
      if (match_cluster != "weighted") {
        if (normalize)
          return(sum(tt[["count"]] > 0, na.rm = TRUE) / length(tt[["count"]]))
        else
          return(sum(tt[["count"]] > 0, na.rm = TRUE))
      } else{
        if (normalize)
          return(sum((tt[["count"]] > 0) * weight, na.rm = TRUE) / length(tt[["count"]]))
        else
          return(sum((tt[["count"]] > 0) * weight, na.rm = TRUE))
      }
    }

    if (method == "sum_transitions") {
      if (normalize)
        return(sum(tt[["count"]], na.rm = TRUE) /
            sum(smc_countMatrix(x@tracds_d$mm)) /
            nrow(tt))
      else
        return(sum(tt[["count"]], na.rm = TRUE) /
            sum(smc_countMatrix(x@tracds_d$mm)))
    }

    if (method == "log_loss") {
      return(-sum(log2(tt[["probability"]])) / length(tt[["probability"]]))
    }

    if (method == "likelihood") {
      ### this is the unnormalized product
      return(prod(tt[["probability"]]))
    }

    if (method == "log_likelihood") {
      ### this is the unnormalized product
      return(sum(log(tt[["probability"]])))
    }

    if (method == "AIC") {
      ### AICc = 2k - 2 ln(L) * 2k(k+1)/(n-k-1)
      ### minimum AIC for model selection

      ### we use supported transitions a the Likelihood
      L <-
        sum(tt[["count"]] > 0, na.rm = TRUE) / length(tt[["count"]])
      ### complexity is number of transitions
      k <- ntransitions(x, threshold = threshold)
      ### number of transitions
      n <- length(tt[["count"]])

      return(2 * k - 2 * log(L) * 2 * k * (k - 1) / (n - k - 1))
    }

    if (method == "product") {
      if (normalize)
        return(prod(tt[["probability"]]) ^ (1 / length(tt[["probability"]])))
      else
        return(prod(tt[["probability"]]))
    }

    if (method == "log_sum") {
      if (normalize)
        return(sum(log10(tt[["probability"]])) / length(tt[["probability"]]))
      else
        return(sum(log10(tt[["probability"]])))
    }

    if (method == "sum") {
      if (normalize)
        return(sum(tt[["probability"]]) / length(tt[["probability"]]))
      else
        return(sum(tt[["probability"]]))
    }

    stop("Unknown method!")

  })


### score two models
#' @rdname score
setMethod("score", signature(x = "EMM", newdata = "EMM"),
  function(x,
    newdata,
    method = c("product", "log_sum", "sum",
      "supported_transitions"),
    match_cluster = "exact",
    random = FALSE,
    prior = TRUE,
    initial_transition = FALSE) {
    method <- match.arg(method)

    ### find transitions in newdata
    trans <- transitions(newdata)

    ### match states in newdata to x
    cl <- find_clusters(x, cluster_centers(newdata),
      match_cluster = match_cluster)

    ### translate to states in x
    cl <-
      cbind(cl[as.integer(trans[, 1])], cl[as.integer(trans[, 2])])

    if (random)
      cl[, 2] <- cl[sample(seq(nrow(cl))), 2, drop = FALSE]

    ### FIXME: add weighted versions. What weights should we use?

    if (method == "product")
      return(prod(
        transition(x, cl, type = "probability",
          prior = prior) ^ (1 / nrow(cl))
      ))

    if (method == "sum")
      return(sum(
        transition(x, cl, type = "probability",
          prior = prior) * (1 / nrow(cl))
      ))

    if (method == "log_sum")
      return(sum(log(
        transition(x, cl, type = "probability",
          prior = prior)
      ) * (1 / nrow(cl))))

    if (method == "supported_transitions")
      return((nrow(cl) - sum(
        transition(x, cl, type = "count",
          prior = FALSE) == 0
      )) / nrow(cl))

  })
