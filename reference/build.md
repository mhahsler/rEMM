# Building an EMM using New Data

Add new data to an EMM.

## Usage

``` r
build(x, newdata, ...)
```

## Arguments

- x:

  an `EMM` object. Note that the function will change the original EMM!

- newdata:

  a vector (one observation), or a matrix or data.frame (each row is an
  observation)

- ...:

  further arguments. If `newdata` is a matrix or a data.frame then
  `verbose = TRUE` can be used to monitor the progress of building the
  model.

## Value

A reference to the changed EMM object with the data added. Note: EMM
objects store all variable data in an environment which enables us to
update partial data without copying the whole object. Assignment will
not create a copy! Use the provided method
[`copy()`](http://michael.hahsler.net/rEMM/reference/EMM-class.md).

## Details

`build()` performs clustering and also updates the TRACDS temporal
layer.

`NA`s are handled in the data by using only the other dimensions if the
data for dissimilarity computation (see package proxy).

## See also

Class
[`TRACDS`](http://michael.hahsler.net/rEMM/reference/TRACDS-class.md),
[`fade`](http://michael.hahsler.net/rEMM/reference/fade.md) and `dist`
in proxy.

## Examples

``` r
## load EMMTraffic data
data("EMMTraffic")
EMMTraffic
#>    Loc_1 Loc_2 Loc_3 Loc_4 Loc_5 Loc_6 Loc_7
#> 1     20    50   100    30    25     4    10
#> 2     20    80    50    20    10    10    10
#> 3     40    30    75    20    30    20    25
#> 4     15    60    30    30    10    10    15
#> 5     40    15    25    10    35    40     9
#> 6      5     5    40    35    10     5     4
#> 7      0    35    55     2     1     3     5
#> 8     20    60    30    11    20    15    10
#> 9     45    40    15    18    20    20    15
#> 10    15    20    40    40    10    10    14
#> 11     5    45    55    10    10    15     0
#> 12    10    30    10     4    15    15    10

## create EMM
emm <- EMM(measure="eJaccard", threshold=0.2)

## build model using EMMTraffic data (note that the EMM object is
## changed without assignment!)
build(emm, EMMTraffic)
## same as: emm <- build(emm, EMMTraffic)

size(emm)
#> [1] 7
plot(emm)


## emm2 <- emm does not create a copy (just a reference)
## a "deep" copy is created using copy()
emm2<- copy(emm)

## convert the emm into a graph
as.igraph(emm)
#> IGRAPH 341540d DNW- 7 9 -- 
#> + attr: name (v/c), weight (e/n)
#> + edges from 341540d (vertex names):
#> [1] 1->2 2->1 2->3 2->6 3->4 4->5 5->2 5->7 6->4
```
