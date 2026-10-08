# Three well separated states make assignments and counts unambiguous.
sequence_data <- function(sequence = c(1, 2, 1, 3, 1, 2, 1)) {
  centers <- rbind(c(0, 0), c(10, 0), c(0, 10))
  colnames(centers) <- c("x", "y")
  centers[sequence, , drop = FALSE]
}

sequence_model <- function(sequence = c(1, 2, 1, 3, 1, 2, 1),
  lambda = 0) {
  EMM(threshold = 0.5, measure = "euclidean", lambda = lambda,
    data = sequence_data(sequence))
}

sequence_counts <- function() {
  matrix(c(0, 2, 1, 2, 0, 0, 1, 0, 0), nrow = 3, byrow = TRUE,
    dimnames = list(as.character(1:3), as.character(1:3)))
}

# Compare public model contents instead of environment identities.
model_contents <- function(model) {
  list(
    centers = cluster_centers(model),
    counts = cluster_counts(model),
    transitions = transition_matrix(model, type = "counts", prior = FALSE),
    initial = initial_transition(model, type = "counts", prior = FALSE),
    current = current_state(model)
  )
}
