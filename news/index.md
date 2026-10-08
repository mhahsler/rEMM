# Changelog

## rEMM 1.2.3 (unreleased)

- Added a getting started vignette.
- Added a vignette on modeling temporal structure with stream clusterers
  and TRACDS.
- Switch to roxygen documentation.
- Updated and added tests.
- Fixed multi-step prediction, default fading, copied temporal model
  fading, and state bookkeeping when merging, removing, or updating
  states. TRAC now preserves cluster labels in its centers and temporal
  model.
- Updated plotting and graph conversion to use current igraph function
  names.

## Changes in version 1.2.2 (08/09/2025)

- Fixed partial argument matching issues.

## Changes in version 1.2.1 (04/21/2024)

CRAN release: 2024-04-21

- added missing package anchor in man pages.  
- removed C++ code.
- proxy and igraph are now imported.

## Changes in version 1.2.0 (06/25/2022)

CRAN release: 2022-06-25

- added interface for package stream

## Changes in version 1.1.1 (05/31/2022)

CRAN release: 2022-05-31

- score gained parameter random
- cleanup.

## Changes in version 1.1.0 (10/27/2021)

CRAN release: 2021-10-29

- Moved to Github.
- Updated package structure to new standards.

## Changes in version 1.0-11 (07/23/2015)

CRAN release: 2015-07-24

- Fixed NAMESPACE (non-standard imports)

## Changes in version 1.0-9 (5/15/2015)

CRAN release: 2015-05-15

- Fixed dependencies in NAMESPACE
- Fixed problems with testthat

## Changes in version 1.0-8 (1/14/2014)

CRAN release: 2014-01-14

- score: match_clusters can now be “exact”, “nn” or “weighted”, where
  weighted replaces all the weighted scores.
- added smooth_transitions (experimental)
- plus_one is now called prior (since it adds a uniform prior for
  transition probabilities)
- score has now an argument called normalize

## Changes in version 1.0-7

CRAN release: 2013-08-11

- improved plot for tNN
- tNN: centroids stop moving to prevent 2 clusters from colliding
- fixed bug with getting transitions from a TRACDS object with 0
  transitions
- find_clusters also accepts now a threshold factor for match_clusters
- score: weights for scoring are now normalized for threshold
- transition from igraph0 to igraph

## Changes in version 1.0-6

CRAN release: 2012-05-30

- Improved performance for prune()
- Added object.size() which also reports memory used by the model
- Switched to igraph0

## Changes in version 1.0-5

CRAN release: 2012-04-09

- Added several methods for score.
- Threshold for pruning and finding rare clusters/transitions is now
  less or equal instead of just less

## Changes in version 1.0-3

CRAN release: 2012-02-08

- Finished the transition to reference objects implemented using
  environments.
- transition_table() now has for consistency also the default of add_one
  set to FALSE.
- last_clustering() was added as an accessor function to tNN.
- ‘igraph’ is now the default plot method.
- Added combining EMMs.
- Added reclustering using tNN.
- Added coloring of states and transitions to plot().
- Added coercion functions as.igraph() and as.graph from TRACDS.

## Changes in version 1.0-2

CRAN release: 2011-07-26

- service release
