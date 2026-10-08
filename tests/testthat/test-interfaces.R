test_that("the stream EMM interface agrees with direct model building", {
  points <- sequence_data()
  dsd <- stream::DSD_Memory(points)
  dsc <- DSC_EMM(threshold = 0.5)
  update(dsc, dsd, n = nrow(points))

  expect_s3_class(dsc, "DSC_EMM")
  expect_equal(model_contents(get_EMM(dsc)), model_contents(sequence_model()))
  expect_equal(as.matrix(stream::get_centers(dsc)), cluster_centers(get_EMM(dsc)))
  expect_equal(stream::get_weights(dsc), cluster_counts(get_EMM(dsc)))

  replacement <- sequence_model(c(1, 2))
  set_EMM(dsc, replacement)
  expect_equal(model_contents(get_EMM(dsc)), model_contents(replacement))
})

test_that("the stream tNN interface respects feature selection", {
  points <- as.data.frame(sequence_data())
  points$unused <- seq_len(nrow(points)) * 100
  dsd <- stream::DSD_Memory(points)
  dsc <- DSC_tNN(formula = ~ x + y, threshold = 0.5)
  update(dsc, dsd, n = nrow(points))

  expect_s3_class(dsc, "DSC_tNN")
  expect_equal(unname(stream::get_weights(dsc)), c(4, 2, 1))
  expect_equal(as.matrix(stream::get_centers(dsc)), cluster_centers(sequence_model()))
})

test_that("TRAC adds transitions to existing cluster assignments", {
  assignments <- c(1, 2, 1, 3, 1, 2, 1)
  points <- sequence_data(assignments)
  emm <- TRAC(assignments, data = points)

  expect_s4_class(emm, "EMM")
  expect_equal(cluster_counts(emm), c("1" = 4, "2" = 2, "3" = 1))
  expect_equal(transition_matrix(emm, type = "counts", prior = FALSE),
    sequence_counts())
  expect_identical(find_clusters(emm, points, match_cluster = "nn"),
    as.character(assignments))
})

test_that("graph conversion preserves direction, state names and transition weights", {
  emm <- sequence_model()
  graph <- as.igraph(emm)

  expect_s3_class(graph, "igraph")
  expect_true(igraph::is_directed(graph))
  expect_equal(igraph::vcount(graph), 3)
  expect_equal(igraph::ecount(graph), 4)
  expect_identical(igraph::V(graph)$name, states(emm))
  expect_equal(as.matrix(igraph::as_adjacency_matrix(graph, attr = "weight")),
    sequence_counts())
})

test_that("noninteractive plots work with a file device", {
  emm <- sequence_model()
  before <- model_contents(emm)
  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path)
  on.exit({ grDevices::dev.off(); unlink(path) })
  set.seed(1234)

  for (method in c("igraph", "MDS", "cluster_counts", "transition_counts")) {
    expect_error(plot(emm, method = method), NA)
  }
  expect_error(plot(emm, method = "MDS", data = sequence_data()), NA)
  expect_equal(model_contents(emm), before)
  expect_warning(plot(EMM()), "Empty EMM")
})
