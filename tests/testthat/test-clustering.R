test_that("tNN updates centroids or retains the first representative", {
  points <- rbind(c(0.1, 0), c(0.3, 0), c(10, 0))
  centroid <- tNN(threshold = 0.5, centroids = TRUE)
  representative <- tNN(threshold = 0.5, centroids = FALSE)
  cluster(centroid, points)
  cluster(representative, as.data.frame(points))

  expect_identical(last_clustering(centroid), c("1", "1", "2"))
  expect_equal(unname(cluster_counts(centroid)), c(2, 1))
  expect_equal(unname(cluster_centers(centroid)["1", ]), c(0.2, 0))
  expect_equal(unname(cluster_centers(representative)["1", ]), c(0.1, 0))
})

test_that("tNN handles one observation at a time and copies independently", {
  tnn <- tNN(threshold = 0.5)
  for (point in list(c(0.1, 0), c(0.3, 0), c(10, 0))) cluster(tnn, point)
  independent <- copy(tnn)
  cluster(independent, c(10, 0))

  expect_equal(unname(cluster_counts(tnn)), c(2, 1))
  expect_equal(unname(cluster_counts(independent)), c(2, 2))
})

test_that("find_clusters honors exact, nearest and expanded threshold matching", {
  emm <- sequence_model()
  before <- model_contents(emm)
  points <- rbind(c(0.1, 0), c(0.75, 0))

  expect_identical(find_clusters(emm, points), c("1", NA_character_))
  expect_identical(find_clusters(emm, points, match_cluster = "nn"), c("1", "1"))
  expect_identical(find_clusters(emm, points, match_cluster = 2), c("1", "1"))
  expect_identical(find_clusters(emm, points[1, ]), "1")
  expect_equal(find_clusters(emm, as.data.frame(points)), find_clusters(emm, points))

  matches <- find_clusters(emm, points, match_cluster = "nn", dist = TRUE)
  expect_identical(names(matches), c("state", "dist"))
  expect_identical(matches$state, c("1", "1"))
  expect_equal(matches$dist, c(0.1, 0.75))
  expect_equal(model_contents(emm), before)
  expect_error(find_clusters(emm, points, match_cluster = "invalid"), "arg")
  expect_true(all(is.na(find_clusters(EMM(), points))))
})

test_that("last_clustering can discard assignments without discarding clusters", {
  emm <- sequence_model()
  counts <- cluster_counts(emm)
  assignments <- last_clustering(emm, remove = TRUE)

  expect_identical(assignments, as.character(c(1, 2, 1, 3, 1, 2, 1)))
  expect_identical(last_clustering(emm), NA_character_)
  expect_equal(cluster_counts(emm), counts)
})
