test_that("constructors create empty models with usable accessors", {
  emm <- EMM()
  tnn <- tNN()
  temporal <- TRACDS()

  expect_s4_class(emm, "EMM")
  expect_s4_class(tnn, "tNN")
  expect_s4_class(temporal, "TRACDS")
  expect_equal(size(emm), 0)
  expect_equal(nclusters(tnn), 0)
  expect_equal(nstates(temporal), 0)
  expect_equal(ntransitions(temporal), 0)
  expect_identical(current_state(emm), NA_character_)
  expect_length(cluster_counts(emm), 0)
  expect_equal(dim(transition_matrix(emm, prior = FALSE)), c(0, 0))
  expect_equal(dim(transitions(temporal)), c(0, 2))
})

test_that("building a model records assignments, centers and counts", {
  emm <- EMM(threshold = 0.5)
  result <- withVisible(build(emm, sequence_data()))

  expect_identical(result$value, emm)
  expect_false(result$visible)
  expect_equal(size(emm), 3)
  expect_equal(nclusters(emm), nstates(emm))
  expect_identical(clusters(emm), as.character(1:3))
  expect_equal(cluster_centers(emm),
    matrix(c(0, 0, 10, 0, 0, 10), nrow = 3, byrow = TRUE,
      dimnames = list(as.character(1:3), c("x", "y"))))
  expect_equal(cluster_counts(emm), c("1" = 4, "2" = 2, "3" = 1))
  expect_identical(last_clustering(emm), as.character(c(1, 2, 1, 3, 1, 2, 1)))
  expect_equal(transition_matrix(emm, type = "counts", prior = FALSE),
    sequence_counts())
  expect_identical(current_state(emm), "1")
})

test_that("constructor data and all build input types agree", {
  points <- sequence_data()
  matrix_model <- sequence_model()
  frame_model <- EMM(threshold = 0.5)
  point_model <- EMM(threshold = 0.5)

  build(frame_model, as.data.frame(points))
  for (i in seq_len(nrow(points))) build(point_model, points[i, ])

  expect_equal(model_contents(frame_model), model_contents(matrix_model))
  expect_equal(model_contents(point_model), model_contents(matrix_model))
})

test_that("successive batches preserve the transition across their boundary", {
  points <- sequence_data()
  emm <- EMM(threshold = 0.5)
  build(emm, points[1:3, , drop = FALSE])
  build(emm, points[4:7, , drop = FALSE])

  expect_equal(model_contents(emm), model_contents(sequence_model()))
  expect_identical(last_clustering(emm), as.character(c(3, 1, 2, 1)))
})

test_that("reset separates independent sequences without forgetting the model", {
  emm <- sequence_model()
  before <- model_contents(emm)
  reset(emm)

  expect_identical(current_state(emm), NA_character_)
  expect_equal(cluster_counts(emm), before$counts)
  expect_equal(transition_matrix(emm, type = "counts", prior = FALSE),
    before$transitions)

  build(emm, sequence_data(c(2, 1)))
  expected <- sequence_counts()
  expected["2", "1"] <- 3
  expect_equal(transition_matrix(emm, type = "counts", prior = FALSE), expected)
  expect_equal(initial_transition(emm, type = "counts", prior = FALSE),
    c("1" = 1, "2" = 1, "3" = 0))
})

test_that("assignment shares an EMM but copy isolates later changes", {
  emm <- sequence_model()
  shared <- emm
  independent <- copy(emm)
  before <- model_contents(emm)

  build(shared, sequence_data(2))
  expect_equal(cluster_counts(emm), c("1" = 4, "2" = 3, "3" = 1))
  expect_equal(model_contents(independent), before)
  reset(independent)
  build(independent, sequence_data(3))
  expect_equal(cluster_counts(emm), c("1" = 4, "2" = 3, "3" = 1))
  expect_equal(cluster_counts(independent), c("1" = 4, "2" = 2, "3" = 2))
  expect_identical(current_state(emm), "2")
  expect_identical(current_state(independent), "3")
})

test_that("missing rows separate sequences and partial observations are clustered", {
  emm <- EMM(threshold = 0.5)
  points <- rbind(c(0, 0), c(NA_real_, NA_real_), c(10, 0))
  build(emm, points)

  expect_identical(last_clustering(emm), c("1", NA_character_, "2"))
  expect_equal(unname(cluster_counts(emm)), c(1, 1))
  expect_equal(ntransitions(emm), 0)
  expect_equal(unname(initial_transition(emm, type = "counts", prior = FALSE)),
    c(1, 1))

  partial <- EMM(threshold = 0.5)
  build(partial, rbind(c(0, 0), c(NA_real_, 0.2), c(10, 0)))
  expect_identical(last_clustering(partial), c("1", "1", "2"))
  expect_equal(unname(cluster_centers(partial)["1", ]), c(0, 0.1))
})

test_that("the biological example uses Kullback dissimilarity", {
  data("16S", envir = environment())
  training <- Mollicutes16S + 1
  observed <- rowSums(!is.na(training)) > 0
  emm <- EMM(measure = "Kullback", threshold = 0.1, data = training)

  expect_equal(sum(cluster_counts(emm)), sum(observed))
  expect_length(last_clustering(emm), nrow(training))
  expect_equal(nstates(emm), nclusters(emm))
  expect_identical(clusters(emm), rownames(cluster_centers(emm)))
  expect_equal(sum(transition_matrix(emm, type = "counts", prior = FALSE)),
    sum(observed[-1] & observed[-length(observed)]))
  expect_true(is.finite(score(emm, training, method = "sum")))
})
