test_that("removing clusters also removes incident transitions and keeps the source", {
  emm <- sequence_model()
  before <- model_contents(emm)
  reduced <- remove_clusters(emm, "3")

  expect_identical(states(reduced), c("1", "2"))
  expect_identical(clusters(reduced), states(reduced))
  expect_equal(cluster_counts(reduced), c("1" = 4, "2" = 2))
  expect_equal(transition_matrix(reduced, type = "counts", prior = FALSE),
    sequence_counts()[1:2, 1:2])
  expect_equal(model_contents(emm), before)
  expect_equal(model_contents(remove_clusters(emm, character())), before)
})

test_that("removing the current state resets the sequence boundary", {
  emm <- sequence_model()
  remove_clusters(emm, "1", copy = FALSE)

  expect_identical(current_state(emm), NA_character_)
  build(emm, sequence_data(2))
  expect_equal(initial_transition(emm, type = "counts", prior = FALSE),
    c("2" = 1, "3" = 0))
  expect_equal(ntransitions(emm), 0)
})

test_that("building after removal addresses surviving states and reused storage correctly", {
  emm <- sequence_model()
  remove_clusters(emm, "2", copy = FALSE)
  build(emm, rbind(sequence_data(3), c(20, 20)))

  expect_equal(cluster_counts(emm), c("1" = 4, "3" = 2, "4" = 1))
  expect_equal(transition(emm, "1", "3", type = "counts", prior = FALSE), 2)
  expect_equal(transition(emm, "3", "4", type = "counts", prior = FALSE), 1)
  expect_equal(transition(emm, "4", "3", type = "counts", prior = FALSE), 0)
  expect_identical(current_state(emm), "4")
})

test_that("removal keeps centers as a matrix for one or zero remaining states", {
  emm <- sequence_model()
  single <- remove_clusters(emm, c("2", "3"))
  empty <- remove_clusters(emm, states(emm))

  expect_equal(dim(cluster_centers(single)), c(1, 2))
  expect_equal(nclusters(single), 1)
  expect_equal(dim(cluster_centers(empty)), c(0, 2))
  expect_equal(nclusters(empty), 0)
  expect_equal(nstates(empty), 0)
  build(empty, sequence_data(2))
  expect_equal(nclusters(empty), 1)
  expect_equal(unname(cluster_counts(empty)), 1)
})

test_that("transition removal supports both interfaces and copy semantics", {
  emm <- sequence_model()
  before <- model_contents(emm)
  expected <- sequence_counts()
  expected["1", "2"] <- 0
  reduced <- remove_transitions(emm, "1", "2")
  tabular <- remove_transitions(emm, rbind(c("1", "2")))

  expect_equal(transition_matrix(reduced, type = "counts", prior = FALSE), expected)
  expect_equal(model_contents(tabular), model_contents(reduced))
  expect_equal(cluster_counts(reduced), before$counts)
  expect_equal(model_contents(emm), before)
  remove_transitions(emm, "1", "2", copy = FALSE)
  expect_equal(transition_matrix(emm, type = "counts", prior = FALSE), expected)
  expect_error(remove_transitions(emm, c("1", "2"), "3"), "length")
})

test_that("removing self transitions leaves other transitions and clusters intact", {
  emm <- sequence_model(c(1, 1, 2, 2, 3, 3, 1))
  counts <- transition_matrix(emm, type = "counts", prior = FALSE)
  expected <- counts
  diag(expected) <- 0
  reduced <- remove_selftransitions(emm)

  expect_equal(transition_matrix(reduced, type = "counts", prior = FALSE), expected)
  expect_equal(cluster_counts(reduced), cluster_counts(emm))
  expect_equal(transition_matrix(emm, type = "counts", prior = FALSE), counts)
})

test_that("pruning removes counts at the threshold and supports in-place updates", {
  emm <- sequence_model()
  before <- model_contents(emm)
  expect_identical(rare_clusters(emm, count_threshold = 1), "3")
  reduced <- prune(emm, count_threshold = 1)

  expect_identical(states(reduced), c("1", "2"))
  expect_equal(cluster_counts(reduced), c("1" = 4, "2" = 2))
  expect_equal(transition_matrix(reduced, type = "counts", prior = FALSE),
    sequence_counts()[1:2, 1:2])
  expect_equal(model_contents(emm), before)
  prune(emm, count_threshold = 1, copy = FALSE)
  expect_equal(model_contents(emm), model_contents(reduced))
})

test_that("transition pruning does not remove clusters", {
  emm <- sequence_model()
  pruned <- prune(emm, count_threshold = 1, clusters = FALSE, transitions = TRUE)
  expected <- sequence_counts()
  expected["1", "3"] <- 0
  expected["3", "1"] <- 0

  expect_equal(transition_matrix(pruned, type = "counts", prior = FALSE), expected)
  expect_equal(cluster_counts(pruned), cluster_counts(emm))
  expect_equal(nstates(pruned), 3)
})

test_that("merging uses weighted centers and aggregates transitions", {
  emm <- sequence_model()
  before <- model_contents(emm)
  merged <- merge_clusters(emm, c("2", "1"))
  expected <- matrix(c(4, 1, 1, 0), nrow = 2, byrow = TRUE,
    dimnames = list(c("2", "3"), c("2", "3")))

  expect_identical(states(merged), c("2", "3"))
  expect_equal(cluster_counts(merged), c("2" = 6, "3" = 1))
  expect_equal(unname(cluster_centers(merged)["2", ]), c(10/3, 0))
  expect_equal(transition_matrix(merged, type = "counts", prior = FALSE), expected)
  expect_equal(initial_transition(merged, type = "counts", prior = FALSE),
    c("2" = 1, "3" = 0))
  expect_identical(current_state(merged), "2")
  expect_equal(model_contents(emm), before)
  expect_error(merge_clusters(emm, c("1", "unknown")), "not all clusters")
  merge_clusters(emm, c("2", "1"), copy = FALSE)
  expect_equal(model_contents(emm), model_contents(merged))
})
