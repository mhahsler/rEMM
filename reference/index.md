# Package index

## Package Overview

- [`rEMM`](http://michael.hahsler.net/rEMM/reference/rEMM-package.md)
  [`rEMM-package`](http://michael.hahsler.net/rEMM/reference/rEMM-package.md)
  : Extensible Markov Models for Sequence Data

## Models

- [`EMM()`](http://michael.hahsler.net/rEMM/reference/EMM-class.md) :
  Class "EMM"
- [`tNN()`](http://michael.hahsler.net/rEMM/reference/tNN-class.md) :
  Class "tNN"
- [`TRACDS()`](http://michael.hahsler.net/rEMM/reference/TRACDS-class.md)
  [`as.igraph()`](http://michael.hahsler.net/rEMM/reference/TRACDS-class.md)
  [`as.graph()`](http://michael.hahsler.net/rEMM/reference/TRACDS-class.md)
  : Class "TRACDS"

## Building models

- [`build()`](http://michael.hahsler.net/rEMM/reference/build.md) :
  Building an EMM using New Data
- [`cluster()`](http://michael.hahsler.net/rEMM/reference/cluster.md) :
  Data stream clustering with tNN
- [`compact(`*`<TRACDS>`*`)`](http://michael.hahsler.net/rEMM/reference/update.md)
  [`reset(`*`<TRACDS>`*`)`](http://michael.hahsler.net/rEMM/reference/update.md)
  [`update(`*`<TRACDS>`*`)`](http://michael.hahsler.net/rEMM/reference/update.md)
  : Update a TRACDS temporal structure with new state assignements

## Working with the models

- [`plot(`*`<EMM>`*`,`*`<missing>`*`)`](http://michael.hahsler.net/rEMM/reference/plot.EMM.md)
  : Visualize EMM Objects
- [`find_clusters(`*`<tNN>`*`,`*`<matrix>`*`)`](http://michael.hahsler.net/rEMM/reference/find_clusters.md)
  : Find the EMM State/Cluster for an Observation
- [`recluster_hclust(`*`<EMM>`*`)`](http://michael.hahsler.net/rEMM/reference/recluster.md)
  [`recluster_kmeans(`*`<EMM>`*`)`](http://michael.hahsler.net/rEMM/reference/recluster.md)
  [`recluster_pam(`*`<EMM>`*`)`](http://michael.hahsler.net/rEMM/reference/recluster.md)
  [`recluster_reachability(`*`<EMM>`*`)`](http://michael.hahsler.net/rEMM/reference/recluster.md)
  [`recluster_tNN(`*`<EMM>`*`)`](http://michael.hahsler.net/rEMM/reference/recluster.md)
  [`recluster_transitions(`*`<EMM>`*`)`](http://michael.hahsler.net/rEMM/reference/recluster.md)
  : Reclustering EMM states
- [`merge_clusters(`*`<EMM>`*`,`*`<character>`*`)`](http://michael.hahsler.net/rEMM/reference/merge.md)
  : Merge States of an EMM
- [`remove_clusters()`](http://michael.hahsler.net/rEMM/reference/remove.md)
  [`remove_transitions()`](http://michael.hahsler.net/rEMM/reference/remove.md)
  [`remove_selftransitions()`](http://michael.hahsler.net/rEMM/reference/remove.md)
  : Remove States/Clusters or Transitions from an EMM
- [`rare_transitions()`](http://michael.hahsler.net/rEMM/reference/prune.md)
  [`rare_clusters()`](http://michael.hahsler.net/rEMM/reference/prune.md)
  [`prune(`*`<EMM>`*`)`](http://michael.hahsler.net/rEMM/reference/prune.md)
  : Prune States and/or Transitions
- [`fade()`](http://michael.hahsler.net/rEMM/reference/fade.md) : Fading
  Cluster Structure and EMM Layer
- [`c(`*`<EMM>`*`)`](http://michael.hahsler.net/rEMM/reference/combine.md)
  : Combining EMM Objects

## Transitions and sequence analysis

- [`transition(`*`<TRACDS>`*`,`*`<character>`*`,`*`<character>`*`)`](http://michael.hahsler.net/rEMM/reference/transition.md)
  [`transition_matrix(`*`<TRACDS>`*`)`](http://michael.hahsler.net/rEMM/reference/transition.md)
  [`initial_transition(`*`<TRACDS>`*`)`](http://michael.hahsler.net/rEMM/reference/transition.md)
  : Access Transition Probabilities/Counts in an EMM
- [`transition_table(`*`<EMM>`*`,`*`<matrix>`*`)`](http://michael.hahsler.net/rEMM/reference/transition_table.md)
  : Extract a Transition Table for a New Sequence Given an EMM
- [`smooth_transitions(`*`<EMM>`*`)`](http://michael.hahsler.net/rEMM/reference/smooth_transitions.md)
  : Smooths transition counts between neighboring states/clusters
- [`score(`*`<EMM>`*`,`*`<matrix>`*`)`](http://michael.hahsler.net/rEMM/reference/score.md)
  [`score(`*`<EMM>`*`,`*`<EMM>`*`)`](http://michael.hahsler.net/rEMM/reference/score.md)
  : Score a New Sequence Given an EMM
- [`predict(`*`<TRACDS>`*`)`](http://michael.hahsler.net/rEMM/reference/predict.md)
  : Predict a Future State

## Temporal Structure for Standard Clustering Algorithms

- [`TRAC()`](http://michael.hahsler.net/rEMM/reference/TRAC-class.md) :
  TRAC: Creating a Markov Model from a Regular Clustering

## Stream Interface Classes

- [`DSC_EMM()`](http://michael.hahsler.net/rEMM/reference/DSC_EMM.md)
  [`get_EMM()`](http://michael.hahsler.net/rEMM/reference/DSC_EMM.md)
  [`set_EMM()`](http://michael.hahsler.net/rEMM/reference/DSC_EMM.md)
  [`DSC_tNN()`](http://michael.hahsler.net/rEMM/reference/DSC_EMM.md) :
  DSC Interface for EMM and tNN (package stream)

## Data

- [`synthetic_stream()`](http://michael.hahsler.net/rEMM/reference/synthetic_stream.md)
  : Create a Synthetic Data Stream
- [`EMMsim`](http://michael.hahsler.net/rEMM/reference/EMMsim.md) :
  Synthetic Data to Demonstrate EMMs
- [`EMMTraffic`](http://michael.hahsler.net/rEMM/reference/EMMTraffic.md)
  : Hypothetical Traffic Data Set for EMM
- [`Derwent`](http://michael.hahsler.net/rEMM/reference/Derwent.md) :
  Derwent Catchment Data
- [`` `16S` ``](http://michael.hahsler.net/rEMM/reference/rRNA16S.md) :
  Count Data for 16S rRNA Sequences
