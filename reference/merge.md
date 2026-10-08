# Merge States of an EMM

Merge several clusters/states of an EMM into a single cluster/state.

## Usage

``` r
# S4 method for class 'EMM,character'
merge_clusters(x, to_merge, clustering = FALSE, new_center = NULL, copy = TRUE)
```

## Arguments

- x:

  an `"EMM"` object. Note that the function will change this EMM!

- to_merge:

  vector of names of the states/clusters to merge. The name of the first
  state in `to_merge` is used as the name for the new state representing
  the merged states.

- clustering:

  is `to_merge` a vector with cluster assignments as created by a
  clustering algorithm?

- new_center:

  supply new centers for the merged clusters. New centroids are
  automatically computed. If (pseudo) medoids are used, new medoids
  should be supplied. If none is supplied, the medoid of the cluster in
  `to_merge` which has the most assigned observations is used as the new
  medoid (warning: this is probably not a good medoid!)

- copy:

  logical; make a copy of x before reclustering? Otherwise the function
  will change `x`!

## Value

Returns the changed EMM with the states/clusters merged invisibly. If
`copy=FALSE` then it returns a reference to the changes object passed as
`x`.

## Examples

``` r
data("EMMTraffic")
emm <- EMM(measure="eJaccard", threshold=0.2)
build(emm, EMMTraffic)
states(emm)
#> [1] "1" "2" "3" "4" "5" "6" "7"

## create a new emm with states 1-3 merged
emm_m123 <- merge_clusters(emm, c("1", "2", "3"))
states(emm_m123)
#> [1] "1" "4" "5" "6" "7"
```
