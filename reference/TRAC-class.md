# TRAC: Creating a Markov Model from a Regular Clustering

Create an Markov model from a regular clustering (k-means or PAM) of
sequence data.

## Usage

``` r
TRAC(x, data = NULL, centers = NULL, measure = "euclidean")
```

## Arguments

- x:

  a clustering object (result of kmeans or PAM), a data set (a data
  matrix), or a vector with (integer) cluster assignments.

- data:

  the data used for clustering (only used if `x` is a cluster assignment
  vector).

- centers:

  if `x` is a cluster assignment vector, then a data.frame or matrix
  with the cluster centers needs to be supplies. Otherwise, `centers` is
  ignored.

- measure:

  used distance measure.

## Value

A `EMM` object representing the clustering of sequence data.

## Details

The order is inferred from the order in the original data set.

## Examples

``` r
data("EMMsim")

## using kmeans
cl <- kmeans(EMMsim_train, 10)
emm <- TRAC(cl)
emm
#> EMM with 10 states/clusters.
#>  Measure: euclidean 
#>  Threshold: 0.499165 
#>  Centroid: TRUE 
#>  Lambda: 0 
plot(emm, method = "MDS")


## using a cluster assignment vector (taken from the k-means clustering above)
x <- cl$cluster
emm <- TRAC(x, data = EMMsim_train)
emm
#> EMM with 10 states/clusters.
#>  Measure: euclidean 
#>  Threshold: 0.4028334 
#>  Centroid: TRUE 
#>  Lambda: 0 
plot(emm, method = "MDS")
```
