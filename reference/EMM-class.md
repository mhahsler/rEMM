# Class "EMM"

This class represents the extensible Markov Model. It consists of a
simple data stream clustering algorithm (class `"tNN"`) and a temporal
layer (class `"TRACDS"`).

Create a new object of class `"EMM"`.

## Usage

``` r
EMM(
  threshold = 0.2,
  measure = "euclidean",
  distFun = NULL,
  centroids = identical(tolower(measure), "euclidean"),
  lambda = 0,
  data = NULL
)
```

## Arguments

- threshold:

  Object of class `"numeric"` with the dissimilarity threshold used by
  the clustering algorithm for assigning a new observation to existing
  clusters.

- measure:

  Object of class `"character"` containing the name of the dissimilarity
  measure used (see `dist` in proxy for available measures).

- distFun:

  Specify a function passed on as method to `dist` in proxy (see `dist`
  in proxy). The character string passed on as `measure` will be used as
  the measure's name.

- centroids:

  Object of class `"logical"` indicating if centroids are used for
  clusters. If `FALSE`, pseudo medians (first observation of a cluster)
  are used to represent a cluster.

- lambda:

  Object of class `"numeric"` specifying the rate for fading.

- data:

  Initial data to build the EMM. This just calls `build` on the new EMM.

## Value

An object of class `"EMM"`.

## Objects from the Class

Objects can be created using the creator function `EMM` or by directly
calling `new("EMM", ...)`. Most slots for the extended classes can be
used as parameters for `EMM`.

## Slots

The slots are described in corresponding the extended classes (see
section Extends).

## Extends

Class
`"`[`tNN`](https://michael.hahsler.net/rEMM/reference/tNN-class.md)`"`,
directly. Class
`"`[`TRACDS`](https://michael.hahsler.net/rEMM/reference/TRACDS-class.md)`"`,
directly.

## Methods

- copy:

  `signature(x = "EMM")`: Make a copy of the EMM object. Making explicit
  copies is necessary since the subclasses store information in
  environments which are not copied for regular assignements.

- size:

  `signature(x = "EMM")`: Returns the size of the EMM (number of
  clusters/states).

## References

M.H. Dunham, Y. Meng, J. Huang (2004): Extensible Markov Model, In:
*ICDM '04: Proceedings of the Fourth IEEE International Conference on
Data Mining,* pp. 371–374.

## See also

[`build`](https://michael.hahsler.net/rEMM/reference/build.md),
[`fade`](https://michael.hahsler.net/rEMM/reference/fade.md),
[`merge_clusters`](https://michael.hahsler.net/rEMM/reference/merge.md),
[`plot`](https://michael.hahsler.net/rEMM/reference/plot.EMM.md),
[`prune`](https://michael.hahsler.net/rEMM/reference/prune.md),
[`rare_clusters`](https://michael.hahsler.net/rEMM/reference/prune.md),
[`rare_transitions`](https://michael.hahsler.net/rEMM/reference/prune.md),
[`remove_clusters`](https://michael.hahsler.net/rEMM/reference/remove.md),
[`remove_transitions`](https://michael.hahsler.net/rEMM/reference/remove.md),
[`remove_selftransitions`](https://michael.hahsler.net/rEMM/reference/remove.md),
[`recluster`](https://michael.hahsler.net/rEMM/reference/recluster.md),
and [`score`](https://michael.hahsler.net/rEMM/reference/score.md).

`EMM-class`

## Examples

``` r
## load EMMTraffic data
data(EMMTraffic)

## create empty EMM
emm <- EMM(threshold=0.2, measure="eJaccard", lambda=.1)
emm
#> EMM with 0 states/clusters.
#>  Measure: eJaccard 
#>  Threshold: 0.2 
#>  Centroid: FALSE 
#>  Lambda: 0.1 

## cluster some data
build(emm, EMMTraffic)
emm
#> EMM with 7 states/clusters.
#>  Measure: eJaccard 
#>  Threshold: 0.2 
#>  Centroid: FALSE 
#>  Lambda: 0.1 

## what clusters were the data points assigned to?
last_clustering(emm)
#>  [1] "1" "2" "1" "2" "3" "4" "5" "2" "6" "4" "5" "7"

## plot the clustering as a graph
plot(emm)
```
