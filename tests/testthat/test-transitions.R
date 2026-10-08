test_that("TRACDS learns labeled sequences and treats missing assignments as boundaries", {
  temporal <- TRACDS()
  update(temporal, c("start", "middle", "start", NA, "end"))
  expected <- matrix(c(0, 1, 0, 1, 0, 0, 0, 0, 0), nrow = 3, byrow = TRUE,
    dimnames = list(c("start", "middle", "end"), c("start", "middle", "end")))

  expect_identical(states(temporal), c("start", "middle", "end"))
  expect_identical(current_state(temporal), "end")
  expect_equal(transition_matrix(temporal, type = "counts", prior = FALSE), expected)
  expect_equal(initial_transition(temporal, type = "counts", prior = FALSE),
    c(start = 1, middle = 0, end = 1))
  expect_equal(ntransitions(temporal), 2)
})

test_that("transition probabilities reflect counts and add-one smoothing", {
  emm <- sequence_model()
  expected <- matrix(c(0, 2/3, 1/3, 1, 0, 0, 1, 0, 0), nrow = 3, byrow = TRUE,
    dimnames = list(as.character(1:3), as.character(1:3)))
  smoothed <- matrix(c(1/6, 3/6, 2/6, 3/5, 1/5, 1/5, 2/4, 1/4, 1/4),
    nrow = 3, byrow = TRUE, dimnames = dimnames(expected))

  expect_equal(transition_matrix(emm, prior = FALSE), expected)
  expect_equal(transition_matrix(emm), smoothed)
  expect_equal(transition_matrix(emm, type = "counts"), sequence_counts() + 1)
  expect_equal(transition_matrix(emm, type = "log_odds"), log(smoothed * 3))
  expect_equal(initial_transition(emm, prior = FALSE), c("1" = 1, "2" = 0, "3" = 0))
  expect_equal(initial_transition(emm), c("1" = 0.5, "2" = 0.25, "3" = 0.25))
})

test_that("states without outgoing observations are absorbing without a prior", {
  temporal <- TRACDS()
  update(temporal, c("a", "b"))

  expect_equal(unname(transition_matrix(temporal, prior = FALSE)),
    matrix(c(0, 1, 0, 1), nrow = 2, byrow = TRUE))
  expect_equal(rowSums(transition_matrix(temporal)), c(a = 1, b = 1))
})

test_that("individual and tabular transition queries return known counts", {
  emm <- sequence_model()
  pairs <- rbind(c("1", "2"), c("1", "3"), c("2", "3"))

  expect_equal(transition(emm, pairs, type = "counts", prior = FALSE), c(2, 1, 0))
  expect_equal(transition(emm, as.data.frame(pairs), type = "counts", prior = FALSE),
    c(2, 1, 0))
  expect_equal(transition(emm, "1", "2", prior = FALSE), 2/3)
  expect_equal(transition(emm, character(), character()), numeric())
  expect_error(transition(emm, c("1", "2"), "3"), "same length")
  expect_equal(ntransitions(emm), 4)
  expect_equal(ntransitions(emm, threshold = 2), 2)
  rare <- rare_transitions(emm, count_threshold = 1)
  expect_equal(nrow(rare), 2)
  expect_equal(transition(emm, rare, type = "counts", prior = FALSE), c(1, 1))
})

test_that("transition_table preserves observation order and includes initial probabilities", {
  emm <- sequence_model()
  points <- sequence_data(c(1, 2, 1, 3))
  table <- transition_table(emm, points, prior = FALSE)

  expect_identical(table$from, c("1", "2", "1"))
  expect_identical(table$to, c("2", "1", "3"))
  expect_equal(table$probability, c(2/3, 1, 1/3))
  expect_equal(transition_table(emm, as.data.frame(points), prior = FALSE), table)
  initial <- transition_table(emm, points, prior = FALSE, initial_transition = TRUE)
  expect_identical(initial$from, c(NA_character_, "1", "2", "1"))
  expect_identical(initial$to, c("1", "2", "1", "3"))
  expect_equal(initial$probability, c(1, 2/3, 1, 1/3))
})

test_that("compaction preserves counts and allows additional states", {
  temporal <- TRACDS()
  labels <- paste0("state", seq_len(25))
  update(temporal, rep(labels, 2))
  before <- transition_matrix(temporal, type = "counts", prior = FALSE)
  initial <- initial_transition(temporal, type = "counts", prior = FALSE)
  compact(temporal)

  expect_equal(transition_matrix(temporal, type = "counts", prior = FALSE), before)
  expect_equal(initial_transition(temporal, type = "counts", prior = FALSE), initial)
  expect_identical(current_state(temporal), labels[25])
  update(temporal, c("new", labels[1]))
  expect_equal(nstates(temporal), 26)
  expect_equal(transition(temporal, labels[25], "new", type = "counts", prior = FALSE), 1)
  expect_equal(transition(temporal, "new", labels[1], type = "counts", prior = FALSE), 1)
})

test_that("copying a temporal model preserves its fading behavior", {
  temporal <- TRACDS(lambda = 1)
  update(temporal, c("a", "b"))
  independent <- copy(temporal)
  before <- transition_matrix(temporal, type = "counts", prior = FALSE)

  update(independent, "a")
  expect_equal(transition_matrix(temporal, type = "counts", prior = FALSE), before)
  expect_equal(transition(independent, "a", "b", type = "counts", prior = FALSE), 0.5)
  expect_equal(transition(independent, "b", "a", type = "counts", prior = FALSE), 1)
})
