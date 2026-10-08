test_that("hierarchical reclustering preserves mass and temporal structure", {
  centers <- rbind(c(0, 0), c(0.2, 0), c(10, 0), c(10.2, 0))
  points <- centers[rep(1:4, 2), , drop = FALSE]
  emm <- EMM(threshold = 0.05, data = points)
  before <- model_contents(emm)
  clustered <- recluster_hclust(emm, k = 2, method = "average")

  expect_equal(size(clustered), 2)
  expect_equal(unname(cluster_counts(clustered)), c(4, 4))
  expect_equal(unname(cluster_centers(clustered)), rbind(c(0.1, 0), c(10.1, 0)))
  expect_equal(unname(transition_matrix(clustered, type = "counts", prior = FALSE)),
    matrix(c(2, 2, 1, 2), nrow = 2, byrow = TRUE))
  expect_true(current_state(clustered) %in% states(clustered))
  expect_s3_class(attr(clustered, "cluster_info")$dendrogram, "hclust")
  expect_equal(model_contents(emm), before)
  recluster_hclust(emm, k = 2, copy = FALSE)
  expect_equal(model_contents(emm), model_contents(clustered))
})

test_that("hierarchical reclustering can return multiple model sizes", {
  emm <- sequence_model()
  models <- recluster_hclust(emm, k = c(2, 3))

  expect_length(models, 2)
  expect_equal(vapply(models, size, numeric(1)), c(2, 3))
  expect_equal(vapply(models, function(x) sum(cluster_counts(x)), numeric(1)), c(7, 7))
  expect_equal(vapply(models, function(x) sum(transition_matrix(x,
    type = "counts", prior = FALSE)), numeric(1)), c(6, 6))
  expect_equal(size(emm), 3)
})

test_that("explicit fading scales counts without moving centers", {
  emm <- sequence_model()
  before <- model_contents(emm)
  result <- withVisible(fade(emm, t = 2, lambda = 0.5))

  expect_identical(result$value, emm)
  expect_false(result$visible)
  expect_equal(cluster_centers(emm), before$centers)
  expect_equal(cluster_counts(emm), before$counts / 2)
  expect_equal(transition_matrix(emm, type = "counts", prior = FALSE),
    before$transitions / 2)
  expect_equal(initial_transition(emm, type = "counts", prior = FALSE),
    before$initial / 2)

  fade(emm, lambda = 1)
  expect_equal(cluster_counts(emm), before$counts / 4)
})

test_that("fading defaults to the model rate and one time interval", {
  emm <- sequence_model(lambda = 1)
  counts <- cluster_counts(emm)
  transitions <- transition_matrix(emm, type = "counts", prior = FALSE)
  fade(emm)

  expect_equal(cluster_counts(emm), counts / 2)
  expect_equal(transition_matrix(emm, type = "counts", prior = FALSE), transitions / 2)
  fade(emm, t = 2)
  expect_equal(cluster_counts(emm), counts / 8)

  unfaded <- sequence_model()
  before <- model_contents(unfaded)
  fade(unfaded)
  expect_equal(model_contents(unfaded), before)
})

test_that("automatic fading discounts old observations while building", {
  emm <- sequence_model(c(1, 1), lambda = 1)

  expect_equal(cluster_counts(emm), c("1" = 1.5))
  expect_equal(transition(emm, "1", "1", type = "counts", prior = FALSE), 1)
  expect_equal(initial_transition(emm, type = "counts", prior = FALSE), c("1" = 0.5))
})
