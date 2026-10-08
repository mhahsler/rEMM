# Extensible Markov Models for Sequence Data

Model clusters and their temporal relationships using an extensible
Markov chain. See
[`vignette("rEMM")`](http://michael.hahsler.net/rEMM/articles/rEMM.md)
for a getting started guide.

## Models

[`EMM`](http://michael.hahsler.net/rEMM/reference/EMM-class.md) combines
data stream clustering with a temporal model.
[`tNN`](http://michael.hahsler.net/rEMM/reference/tNN-class.md) provides
threshold nearest neighbor clustering, and
[`TRACDS`](http://michael.hahsler.net/rEMM/reference/TRACDS-class.md)
learns temporal relationships from cluster assignments.

## Temporal Structure for Standard Clustering Algorithms

[`TRAC`](http://michael.hahsler.net/rEMM/reference/TRAC-class.md) adds a
Markov model to an existing clustering of sequence data, such as a
k-means or PAM clustering.

## Building models

[`build`](http://michael.hahsler.net/rEMM/reference/build.md) adds
observations to an EMM,
[`cluster`](http://michael.hahsler.net/rEMM/reference/cluster.md) adds
observations to a tNN clustering, and
[`update`](http://michael.hahsler.net/rEMM/reference/update.md) adds
cluster assignments to a temporal model.

## Working with the models

[`plot`](http://michael.hahsler.net/rEMM/reference/plot.EMM.md)
visualizes a model, and
[`find_clusters`](http://michael.hahsler.net/rEMM/reference/find_clusters.md)
assigns observations to existing clusters without updating the model.
[`recluster`](http://michael.hahsler.net/rEMM/reference/recluster.md)
groups micro-clusters, and
[`merge_clusters`](http://michael.hahsler.net/rEMM/reference/merge.md)
merges specified states.

[`remove`](http://michael.hahsler.net/rEMM/reference/remove.md) removes
specified states or transitions,
[`prune`](http://michael.hahsler.net/rEMM/reference/prune.md) removes
rare states or transitions, and
[`fade`](http://michael.hahsler.net/rEMM/reference/fade.md) reduces the
weight of older observations.
[`combine`](http://michael.hahsler.net/rEMM/reference/combine.md)
combines EMMs.

## Transitions and sequence analysis

[`transition`](http://michael.hahsler.net/rEMM/reference/transition.md)
accesses transition probabilities and counts, and
[`transition_table`](http://michael.hahsler.net/rEMM/reference/transition_table.md)
extracts transitions for a new sequence.
[`smooth_transitions`](http://michael.hahsler.net/rEMM/reference/smooth_transitions.md)
smooths transition counts between neighboring states.
[`score`](http://michael.hahsler.net/rEMM/reference/score.md) measures
how well a sequence agrees with a model, and
[`predict`](http://michael.hahsler.net/rEMM/reference/predict.md)
predicts future states.

## Stream Interface

[`DSC_EMM`](http://michael.hahsler.net/rEMM/reference/DSC_EMM.md) and
[`DSC_tNN`](http://michael.hahsler.net/rEMM/reference/DSC_EMM.md)
provide clusterers for the stream framework.

## Data

[`synthetic_stream`](http://michael.hahsler.net/rEMM/reference/synthetic_stream.md)
generates synthetic sequence data. Bundled examples include
[`EMMsim`](http://michael.hahsler.net/rEMM/reference/EMMsim.md)
(simulated sequences),
[`EMMTraffic`](http://michael.hahsler.net/rEMM/reference/EMMTraffic.md)
(hypothetical traffic observations),
[`Derwent`](http://michael.hahsler.net/rEMM/reference/Derwent.md) (river
flow readings), and
[`rRNA16S`](http://michael.hahsler.net/rEMM/reference/rRNA16S.md) (16S
rRNA sequence counts).

## See also

Useful links:

- <https://github.com/mhahsler/rEMM>

- <http://michael.hahsler.net/rEMM/>

## Author

**Maintainer**: Michael Hahsler <mhahsler@lyle.smu.edu>
([ORCID](https://orcid.org/0000-0003-2716-1405)) \[copyright holder\]

Authors:

- Michael Hahsler <mhahsler@lyle.smu.edu>
  ([ORCID](https://orcid.org/0000-0003-2716-1405)) \[copyright holder\]

Other contributors:

- Margaret H. Dunham \[contributor\]
