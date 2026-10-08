# Data stream clustering with tNN

Cluster new data into an existing tNN object.

## Usage

``` r
cluster(x, newdata, ...)
```

## Arguments

- x:

  a `tNN` object. Note that this function canges the original object!

- newdata:

  a vector (one observation), or a matrix or data.frame (each row is an
  observation).

- ...:

  further arguments like `verbose`.

## Value

A reference to the changed tNN object with the data added. Note: tNN
objects store all variable data in an environment which enables us to
update partial data without copying the whole object. Assignment will
not create a copy! Use the provided method
[`copy()`](http://michael.hahsler.net/rEMM/reference/EMM-class.md).

## Details

`cluster()` implements tNN clustering The dissimilarity between the new
observation and the centers of the clusters is calculated. The new
observation is assigned to the closest cluster if the dissimilarity
value is smaller than the threshold (for the state). If no such state
exists, a new state is created for the observation. This simple
clustering algorithm is called nearest neighbor threshold nearest
neighbor (threshold NN).

`NA`s are handled in the data by using only the other dimensions if the
data for dissimilarity computation (see package~proxy).

The clusters which the data points in the last `cluster()` operation
where assigned to can be retrieved using the method
[`last_clustering()`](http://michael.hahsler.net/rEMM/reference/tNN-class.md).

## See also

Class [`tNN`](http://michael.hahsler.net/rEMM/reference/tNN-class.md),
[`fade`](http://michael.hahsler.net/rEMM/reference/fade.md) and `dist`
in proxy.

## Examples

``` r
## load EMMTraffic data
data(EMMTraffic)

## create empty clustering
tnn <- tNN(threshold = 0.2, measure = "eJaccard")
tnn
#> tNN with 0 clusters.
#>  Measure: eJaccard 
#>  Threshold: 0.2 
#>  Centroid: FALSE 
#>  Lambda: 0 

## cluster some data
cluster(tnn, EMMTraffic)
tnn
#> tNN with 7 clusters.
#>  Measure: eJaccard 
#>  Threshold: 0.2 
#>  Centroid: FALSE 
#>  Lambda: 0 

## what clusters were the data points assigned to?
last_clustering(tnn)
#>  [1] "1" "2" "1" "2" "3" "4" "5" "2" "6" "4" "5" "7"

## plot the clustering as a scatterplot matrix of the cluster centers
plot(tnn)
```
