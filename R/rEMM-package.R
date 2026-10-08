#' Extensible Markov Models for Sequence Data
#'
#' Model clusters and their temporal relationships using an extensible Markov
#' chain. See \code{vignette("rEMM")} for a getting started guide.
#'
#' @section Models:
#' \code{\link{EMM}} combines data stream clustering with a temporal model.
#' \code{\link{tNN}} provides threshold nearest neighbor clustering, and
#' \code{\link{TRACDS}} learns temporal relationships from cluster assignments.
#'
#' @section Temporal Structure for Standard Clustering Algorithms:
#' \code{\link{TRAC}} adds a Markov model to an existing clustering of
#' sequence data, such as a k-means or PAM clustering.
#'
#' @section Building models:
#' \code{\link{build}} adds observations to an EMM,
#' \code{\link{cluster}} adds observations to a tNN clustering, and
#' \code{\link{update}} adds cluster assignments to a temporal model.
#'
#' @section Working with the models:
#' \code{\link{plot}} visualizes a model, and \code{\link{find_clusters}}
#' assigns observations to existing clusters without updating the model.
#' \code{\link{recluster}} groups micro-clusters, and
#' \code{\link{merge_clusters}} merges specified states.
#'
#' \code{\link{remove}} removes specified states or transitions,
#' \code{\link{prune}} removes rare states or transitions, and
#' \code{\link{fade}} reduces the weight of older observations.
#' \code{\link{combine}} combines EMMs.
#'
#' @section Transitions and sequence analysis:
#' \code{\link{transition}} accesses transition probabilities and counts,
#' and \code{\link{transition_table}} extracts transitions for a new sequence.
#' \code{\link{smooth_transitions}} smooths transition counts between
#' neighboring states. \code{\link{score}} measures how well a sequence agrees
#' with a model, and \code{\link{predict}} predicts future states.
#'
#' @section Stream Interface:
#' \code{\link{DSC_EMM}} and \code{\link{DSC_tNN}} provide clusterers for the
#' \pkg{stream} framework.
#'
#' @section Data:
#' \code{\link{synthetic_stream}} generates synthetic sequence data.
#' Bundled examples include \code{\link{EMMsim}} (simulated sequences),
#' \code{\link{EMMTraffic}} (hypothetical traffic observations),
#' \code{\link{Derwent}} (river flow readings), and
#' \code{\link{rRNA16S}} (16S rRNA sequence counts).
#'
#' @keywords internal
#' @import methods igraph stream
#' @importFrom clusterGeneration genPositiveDefMat
#' @importFrom MASS mvrnorm
#' @importFrom graphics arrows barplot lines points strheight strwidth text
#' @importFrom stats predict plogis runif cmdscale cutree hclust kmeans
#' @importFrom proxy dist pr_DB pr_dist2simil
#' @importFrom utils installed.packages tail
#' @importFrom cluster pam
#' @export predict plot
"_PACKAGE"
