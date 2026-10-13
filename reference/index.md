# Package index

## Package Overview

- [`rEMM`](https://michael.hahsler.net/rEMM/reference/rEMM-package.md)
  [`rEMM-package`](https://michael.hahsler.net/rEMM/reference/rEMM-package.md)
  : Extensible Markov Models for Sequence Data

## Models

- [`EMM()`](https://michael.hahsler.net/rEMM/reference/EMM-class.md) :
  Class "EMM"
- [`tNN()`](https://michael.hahsler.net/rEMM/reference/tNN-class.md) :
  Class "tNN"
- [`TRACDS()`](https://michael.hahsler.net/rEMM/reference/TRACDS-class.md)
  [`as.igraph()`](https://michael.hahsler.net/rEMM/reference/TRACDS-class.md)
  [`as.graph()`](https://michael.hahsler.net/rEMM/reference/TRACDS-class.md)
  : Class "TRACDS"

## Building models

- [`build()`](https://michael.hahsler.net/rEMM/reference/build.md) :
  Building an EMM using New Data
- [`cluster()`](https://michael.hahsler.net/rEMM/reference/cluster.md) :
  Data stream clustering with tNN
- [`compact(`*`<TRACDS>`*`)`](https://michael.hahsler.net/rEMM/reference/update.md)
  [`reset(`*`<TRACDS>`*`)`](https://michael.hahsler.net/rEMM/reference/update.md)
  [`update(`*`<TRACDS>`*`)`](https://michael.hahsler.net/rEMM/reference/update.md)
  : Update a TRACDS temporal structure with new state assignements

## Working with the models

- [`plot(`*`<EMM>`*`,`*`<missing>`*`)`](https://michael.hahsler.net/rEMM/reference/plot.EMM.md)
  : Visualize EMM Objects
- [`find_clusters(`*`<tNN>`*`,`*`<matrix>`*`)`](https://michael.hahsler.net/rEMM/reference/find_clusters.md)
  : Find the EMM State/Cluster for an Observation
- [`recluster_hclust(`*`<EMM>`*`)`](https://michael.hahsler.net/rEMM/reference/recluster.md)
  [`recluster_kmeans(`*`<EMM>`*`)`](https://michael.hahsler.net/rEMM/reference/recluster.md)
  [`recluster_pam(`*`<EMM>`*`)`](https://michael.hahsler.net/rEMM/reference/recluster.md)
  [`recluster_reachability(`*`<EMM>`*`)`](https://michael.hahsler.net/rEMM/reference/recluster.md)
  [`recluster_tNN(`*`<EMM>`*`)`](https://michael.hahsler.net/rEMM/reference/recluster.md)
  [`recluster_transitions(`*`<EMM>`*`)`](https://michael.hahsler.net/rEMM/reference/recluster.md)
  : Reclustering EMM states
- [`merge_clusters(`*`<EMM>`*`,`*`<character>`*`)`](https://michael.hahsler.net/rEMM/reference/merge.md)
  : Merge States of an EMM
- [`remove_clusters()`](https://michael.hahsler.net/rEMM/reference/remove.md)
  [`remove_transitions()`](https://michael.hahsler.net/rEMM/reference/remove.md)
  [`remove_selftransitions()`](https://michael.hahsler.net/rEMM/reference/remove.md)
  : Remove States/Clusters or Transitions from an EMM
- [`rare_transitions()`](https://michael.hahsler.net/rEMM/reference/prune.md)
  [`rare_clusters()`](https://michael.hahsler.net/rEMM/reference/prune.md)
  [`prune(`*`<EMM>`*`)`](https://michael.hahsler.net/rEMM/reference/prune.md)
  : Prune States and/or Transitions
- [`fade()`](https://michael.hahsler.net/rEMM/reference/fade.md) :
  Fading Cluster Structure and EMM Layer
- [`c(`*`<EMM>`*`)`](https://michael.hahsler.net/rEMM/reference/combine.md)
  : Combining EMM Objects

## Transitions and sequence analysis

- [`transition(`*`<TRACDS>`*`,`*`<character>`*`,`*`<character>`*`)`](https://michael.hahsler.net/rEMM/reference/transition.md)
  [`transition_matrix(`*`<TRACDS>`*`)`](https://michael.hahsler.net/rEMM/reference/transition.md)
  [`initial_transition(`*`<TRACDS>`*`)`](https://michael.hahsler.net/rEMM/reference/transition.md)
  : Access Transition Probabilities/Counts in an EMM
- [`transition_table(`*`<EMM>`*`,`*`<matrix>`*`)`](https://michael.hahsler.net/rEMM/reference/transition_table.md)
  : Extract a Transition Table for a New Sequence Given an EMM
- [`smooth_transitions(`*`<EMM>`*`)`](https://michael.hahsler.net/rEMM/reference/smooth_transitions.md)
  : Smooths transition counts between neighboring states/clusters
- [`score(`*`<EMM>`*`,`*`<matrix>`*`)`](https://michael.hahsler.net/rEMM/reference/score.md)
  [`score(`*`<EMM>`*`,`*`<EMM>`*`)`](https://michael.hahsler.net/rEMM/reference/score.md)
  : Score a New Sequence Given an EMM
- [`predict(`*`<TRACDS>`*`)`](https://michael.hahsler.net/rEMM/reference/predict.md)
  : Predict a Future State

## Temporal Structure for Standard Clustering Algorithms

- [`TRAC()`](https://michael.hahsler.net/rEMM/reference/TRAC-class.md) :
  TRAC: Creating a Markov Model from a Regular Clustering

## Stream Interface Classes

- [`DSC_EMM()`](https://michael.hahsler.net/rEMM/reference/DSC_EMM.md)
  [`get_EMM()`](https://michael.hahsler.net/rEMM/reference/DSC_EMM.md)
  [`set_EMM()`](https://michael.hahsler.net/rEMM/reference/DSC_EMM.md)
  [`DSC_tNN()`](https://michael.hahsler.net/rEMM/reference/DSC_EMM.md) :
  DSC Interface for EMM and tNN (package stream)

## Data

- [`synthetic_stream()`](https://michael.hahsler.net/rEMM/reference/synthetic_stream.md)
  : Create a Synthetic Data Stream
- [`EMMsim`](https://michael.hahsler.net/rEMM/reference/EMMsim.md) :
  Synthetic Data to Demonstrate EMMs
- [`EMMTraffic`](https://michael.hahsler.net/rEMM/reference/EMMTraffic.md)
  : Hypothetical Traffic Data Set for EMM
- [`Derwent`](https://michael.hahsler.net/rEMM/reference/Derwent.md) :
  Derwent Catchment Data
- [`` `16S` ``](https://michael.hahsler.net/rEMM/reference/rRNA16S.md) :
  Count Data for 16S rRNA Sequences
