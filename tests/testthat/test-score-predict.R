test_that("sequence scores agree with hand-calculated transition probabilities", {
  emm <- sequence_model()
  points <- sequence_data(c(1, 2, 1, 3))
  before <- model_contents(emm)
  product <- 2/9

  expect_equal(score(emm, points, prior = FALSE), product^(1/3))
  expect_equal(score(emm, points, prior = FALSE, normalize = FALSE), product)
  expect_equal(score(emm, points, method = "sum", prior = FALSE), 2/3)
  expect_equal(score(emm, points, method = "log_sum", prior = FALSE), log10(product)/3)
  expect_equal(score(emm, points, method = "supported_transitions"), 1)
  expect_equal(score(emm, points, method = "supported_states"), 1)
  expect_equal(score(emm, points, method = "likelihood", prior = FALSE), product)
  expect_equal(score(emm, points, method = "log_likelihood", prior = FALSE), log(product))
  expect_equal(score(emm, points, method = "log_loss", prior = FALSE), -log2(product)/3)
  expect_equal(score(emm, as.data.frame(points), prior = FALSE), product^(1/3))
  expect_equal(model_contents(emm), before)
})

test_that("unobserved transitions score zero until smoothing is applied", {
  emm <- sequence_model()
  points <- sequence_data(c(2, 3))

  expect_equal(score(emm, points, prior = FALSE), 0)
  expect_identical(score(emm, points, method = "log_sum", prior = FALSE), -Inf)
  expect_equal(score(emm, points, prior = TRUE), 1/5)
  expect_equal(score(emm, points, method = "supported_transitions"), 0)
  expect_equal(score(emm, points, method = "supported_states"), 1)
})

test_that("scoring distinguishes points outside the model from nearest matches", {
  emm <- sequence_model()
  points <- rbind(c(0, 0), c(12, 0))

  expect_equal(score(emm, points, method = "supported_states"), 0.5)
  expect_equal(score(emm, points, prior = FALSE), 0)
  expect_equal(score(emm, points, match_cluster = "nn", prior = FALSE), 2/3)
  expect_equal(score(EMM(), points), 0)
  expect_error(score(emm, points, method = "invalid"), "arg")
})

test_that("weighted matching discounts distance from cluster centers", {
  emm <- sequence_model()
  points <- sequence_data(c(1, 2, 1, 3))
  noisy <- points
  noisy[2, 1] <- 10.3
  clean_score <- score(emm, points, match_cluster = "weighted", prior = FALSE)
  noisy_score <- score(emm, noisy, match_cluster = "weighted", prior = FALSE)

  expect_gt(clean_score, noisy_score)
  expect_gte(noisy_score, 0)
  expect_lt(clean_score, score(emm, points, match_cluster = "nn", prior = FALSE))
})

test_that("a sequence model can be scored against another EMM", {
  emm <- sequence_model()
  candidate <- sequence_model(c(1, 2, 1, 3))
  before <- model_contents(candidate)

  expect_equal(score(emm, candidate, prior = FALSE), (2/9)^(1/3))
  expect_equal(score(emm, candidate, method = "supported_transitions"), 1)
  expect_equal(model_contents(candidate), before)
})

test_that("randomized scoring is reproducible and detects destroyed sequence order", {
  data("EMMsim", envir = environment())
  emm <- EMM(threshold = 0.1, data = EMMsim_train)
  emm <- recluster_hclust(emm, k = 4)
  ordered <- score(emm, EMMsim_test, match_cluster = "nn")
  set.seed(1234)
  shuffled <- score(emm, EMMsim_test, match_cluster = "nn", random = TRUE)
  set.seed(1234)

  expect_equal(score(emm, EMMsim_test, match_cluster = "nn", random = TRUE), shuffled)
  expect_gt(ordered, shuffled)
})

test_that("prediction returns the correct distribution at multiple horizons", {
  emm <- sequence_model()
  before <- model_contents(emm)
  odd <- c("1" = 0, "2" = 2/3, "3" = 1/3)
  even <- c("1" = 1, "2" = 0, "3" = 0)

  for (horizon in 1:4) {
    expect_equal(predict(emm, current_state = "1", n = horizon,
      probabilities = TRUE), if (horizon %% 2) odd else even)
  }
  expect_identical(predict(emm), "2")
  expect_identical(predict(emm, current_state = "2"), "1")
  expect_equal(sum(predict(emm, probabilities = TRUE, prior = TRUE)), 1)
  expect_error(predict(emm, current_state = "unknown"), "State does not exist")
  expect_equal(model_contents(emm), before)
})

test_that("randomized prediction chooses supported states reproducibly", {
  emm <- sequence_model()
  set.seed(1234)
  choices <- replicate(20, predict(emm, current_state = "1", randomized = TRUE))
  set.seed(1234)

  expect_identical(replicate(20, predict(emm, current_state = "1", randomized = TRUE)),
    choices)
  expect_true(all(choices %in% c("2", "3")))
})
