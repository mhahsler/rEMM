### stream interface

# library(rEMM)
# library(stream)
#
# data("EMMTraffic")
# EMMTraffic
#
# stream <- DSD_Memory(EMMTraffic)
# stream
#
# ## create EMM
# emm <- DSC_EMM(measure="eJaccard", threshold=0.2)
#
# ## build model using EMMTraffic data (note that the EMM object is
# ## changed without assignment!)
# update(emm, stream, n = 12)
# emm
#
# reset_stream(stream)
# plot(emm, stream, method = "pca")
# get_centers(emm)
#
# e <- get_EMM(emm)
# plot(e)
# states(e)
# transitions(e)


#' DSC Interface for EMM and tNN (package stream)
#'
#' @name DSC_EMM
#' @rdname DSC_EMM
#' @aliases DSC_EMM
#' @aliases DSC_tNN
#' @aliases get_EMM
#' @aliases set_EMM
#' @description Provides Data Stream Clusterer (DSC) interfaces for EMM and tNN so they can be used in the
#' \pkg{stream} framework.
#' @param formula \code{NULL} to use all features in the stream or a model \link{formula} of the form \code{~ X1 + X2}
#'     to specify the features used for clustering. Only \code{.}, \code{+} and \code{-} are currently
#'     supported in the formula.
#' @param threshold A \code{"numeric"} with the dissimilarity threshold used by the
#'     clustering algorithm for assigning a new observation to existing clusters.
#' @param measure A \code{"character"} containing the name of the dissimilarity
#'     measure used (see \code{dist} in \pkg{proxy} for available measures).
#' @param distFun Specify a function passed on as method to \code{dist} in \pkg{proxy}
#'     (see \code{dist} in \pkg{proxy}).
#'     The character string passed on as \code{measure} will be used as the
#'     measure's name.
#' @param centroids A \code{"logical"} indicating if centroids are used for clusters.
#'     If \code{FALSE}, pseudo medians (first observation of a cluster) are used to
#'     represent a cluster.
#' @param lambda A \code{"numeric"} specifying the
#'     rate for fading.
#' @param dsc an object of class \code{"DSC_EMM"}.
#' @param x an object of class \code{"EMM"}
#' @details DSC_tNN and DSC_EMM wrap the clustering algorithms so they can be used with the stream framework.
#' See \code{\link[stream]{DSC}} for details.
#'
#' \code{get_EMM()} and \code{set_EMM()} can be used to access the EMM object inside the DSC_EMM object.
#' @return An object of class \code{"DSC_EMM"} or \code{"DSC_tNN"}.
#' @examples library(stream)
#'
#' ### tNN clustering example
#'
#' stream <- DSD_Gaussians()
#' stream
#'
#' cl <- DSC_tNN(threshold = .1)
#' cl
#'
#' update(cl, stream, 100)
#' cl
#'
#' get_centers(cl)
#' get_weights(cl)
#'
#' plot(cl, stream)
#'
#' ## EMM clustering example
#' data("EMMsim")
#' plot(EMMsim_train, pch = NA)
#' lines(EMMsim_train, col = "gray")
#' points(EMMsim_train, pch = EMMsim_sequence_train)
#'
#' stream <- DSD_Memory(EMMsim_train)
#' stream
#'
#' cl <- DSC_EMM(threshold = 0.1, measure = "euclidean", lambda = .1)
#' update(cl, stream, n = 200)
#' cl
#'
#' reset_stream(stream)
#' plot(cl, stream, n = 200, method = "pca")
#'
#' # inspect and recluster the EMM in the DSC_EMM object
#' emm <- get_EMM(cl)
#' plot(emm)
#'
#' emm <- recluster_hclust(emm, k = 4, method = "average")
#' plot(emm)
#'
#' set_EMM(cl, emm)
#'
#' reset_stream(stream)
#' plot(cl, stream, n = 200, method = "pca")
#' @keywords models
#' @export
DSC_EMM <- function(formula = NULL, threshold = 0.2, measure = "euclidean", distFun = NULL,
  centroids = identical(tolower(measure), "euclidean"),
  lambda = 0) {
    structure(
      list(
        description = "Extensible Markov Model",
        formula = formula,
        RObj = new("EMM_R", threshold, measure, distFun,
          centroids, lambda)
      ),
      class = c("DSC_EMM","DSC_Micro", "DSC_R", "DSC")
    )
  }


#' @rdname DSC_EMM
#' @export
get_EMM <- function(dsc) dsc$RObj$rEMM_Obj
#' @rdname DSC_EMM
#' @export
set_EMM <- function(dsc, x) dsc$RObj$rEMM_Obj <- x

EMM_R <- setRefClass("EMM_R", fields = list(rEMM_Obj = "ANY",
  colnames = "ANY"))

EMM_R$methods(
  cache = function() {
    stop("SaveDSC not implemented for DSC_EMM!")
  }
)

EMM_R$methods(
  initialize = function(...) {
    rEMM_Obj <<- EMM(...)
    colnames <<- NULL

    .self
  }
)

EMM_R$methods(
  cluster = function(newdata, ...) {
    rEMM::build(rEMM_Obj, newdata)
  }
)

EMM_R$methods(
  get_microweights = function() {
    cluster_counts(rEMM_Obj)
  }
)

EMM_R$methods(
  get_microclusters = function() {
    as.data.frame(cluster_centers(rEMM_Obj))
  }
)
