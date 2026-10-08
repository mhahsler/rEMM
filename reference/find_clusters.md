# Find the EMM State/Cluster for an Observation

Finds the cluster and thus the EMM states for observations.

## Usage

``` r
# S4 method for class 'tNN,matrix'
find_clusters(x, newdata, match_cluster = c("exact", "nn"), dist = FALSE)
```

## Arguments

- x:

  an `EMM` object.

- newdata:

  a matrix/data.frame with observations.

- match_cluster:

  find exact or nearest neighbor (nn) cluster/state. If a number is
  supplied then the threshold times this number is used for exact
  matching.

- dist:

  also report the distance to the chosen cluster/state (as a
  data.frame).

## Value

Returns the name of the matching clusters/states or a data.frame with
columns "state" and "dist" if `dist=TRUE`.

## See also

[`EMM`](http://michael.hahsler.net/rEMM/reference/EMM-class.md) and
[`tNN`](http://michael.hahsler.net/rEMM/reference/tNN-class.md)

## Examples

``` r
data("EMMTraffic")
emm <- EMM(measure="eJaccard", threshold=0.2)
emm <- build(emm, EMMTraffic)

find_clusters(emm, EMMTraffic)
#>  [1] "1" "2" "1" "2" "3" "4" "5" "2" "6" "4" "5" "7"
find_clusters(emm, EMMTraffic, dist=TRUE)
#>    state       dist
#> 1      1 0.00000000
#> 2      2 0.00000000
#> 3      1 0.15032196
#> 4      2 0.11176471
#> 5      3 0.00000000
#> 6      4 0.00000000
#> 7      5 0.00000000
#> 8      2 0.12010506
#> 9      6 0.00000000
#> 10     4 0.12318465
#> 11     5 0.08584278
#> 12     7 0.00000000

## add noise to the data
set.seed(1234)
newdata <- sapply(EMMTraffic, jitter, amount=15)
## default is exact match
find_clusters(emm, newdata, dist=TRUE)
#>    state       dist
#> 1      1 0.05408491
#> 2      2 0.05286973
#> 3      1 0.15165427
#> 4      2 0.08150151
#> 5      3 0.05945714
#> 6      4 0.15528747
#> 7      5 0.11751832
#> 8   <NA> 0.21778607
#> 9      6 0.08516132
#> 10     4 0.10530835
#> 11     5 0.14610730
#> 12  <NA> 0.22954681
## match with nearest neighbor
find_clusters(emm, newdata, match_cluster="nn", dist=TRUE)
#>    state       dist
#> 1      1 0.05408491
#> 2      2 0.05286973
#> 3      1 0.15165427
#> 4      2 0.08150151
#> 5      3 0.05945714
#> 6      4 0.15528747
#> 7      5 0.11751832
#> 8      2 0.21778607
#> 9      6 0.08516132
#> 10     4 0.10530835
#> 11     5 0.14610730
#> 12     7 0.22954681
## exact match only if within .5 times threshold
find_clusters(emm, newdata, match_cluster=.5, dist=TRUE)
#>    state       dist
#> 1      1 0.05408491
#> 2      2 0.05286973
#> 3   <NA> 0.15165427
#> 4      2 0.08150151
#> 5      3 0.05945714
#> 6   <NA> 0.15528747
#> 7   <NA> 0.11751832
#> 8   <NA> 0.21778607
#> 9      6 0.08516132
#> 10  <NA> 0.10530835
#> 11  <NA> 0.14610730
#> 12  <NA> 0.22954681
## exact match only if within 2 times threshold
find_clusters(emm, newdata, match_cluster=2, dist=TRUE)
#>    state       dist
#> 1      1 0.05408491
#> 2      2 0.05286973
#> 3      1 0.15165427
#> 4      2 0.08150151
#> 5      3 0.05945714
#> 6      4 0.15528747
#> 7      5 0.11751832
#> 8      2 0.21778607
#> 9      6 0.08516132
#> 10     4 0.10530835
#> 11     5 0.14610730
#> 12     7 0.22954681
```
