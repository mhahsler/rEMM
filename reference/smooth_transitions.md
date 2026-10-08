# Smooths transition counts between neighboring states/clusters

Each state/cluster gets the average count if all the outgoing
transitions of its neighbors (i.e., clusters which are within range x
its threshold).

## Usage

``` r
# S4 method for class 'EMM'
smooth_transitions(x, range = 2, copy = TRUE)
```

## Arguments

- x:

  an object of class `"EMM"`

- range:

  threshold multiplier for the smoothing range.

- copy:

  logical; make a copy of x before reclustering? Otherwise the function
  will change `x`!

## Value

`smooth_transitions` returns invisibly an object of class `EMM`. If
`copy=FALSE` then it returns a reference to the changes object passed as
`x`.

## See also

[`prune`](http://michael.hahsler.net/rEMM/reference/prune.md)

## Examples

``` r
data("EMMTraffic")

## learn a model
emm <- EMM(threshold=0.2, measure="eJaccard")
build(emm, EMMTraffic)

## smooth the model by adding tansitions
emm_s <- smooth_transitions(emm)

## compare graphs
op <- par(mfrow = c(1, 2), pty = "m")
plot(emm, method="MDS", main="Original")
plot(emm_s, method="MDS", main="Smoothed")

par(op)
```
