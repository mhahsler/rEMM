# Remove States/Clusters or Transitions from an EMM

Remove states/clusters or transitions from an EMM.

## Usage

``` r
remove_clusters(x, to_remove, copy = TRUE)
remove_transitions(x, from, to,copy = TRUE)
remove_selftransitions(x, copy = TRUE)
```

## Arguments

- x:

  an `EMM` object.

- to_remove:

  Names of states/clusters to remove.

- copy:

  logical; make a copy of x before reclustering? Otherwise the function
  will change `x`!

- from, to:

  Names of states for removing transitions. If `to` is missing `from`
  has to contain a matrix with two columns (from and to state names).

## Value

Returns a EMM with removed states/transitions. If `copy=FALSE` a
reference to the object `x` with the states/transistions removed is
returned.

## Details

`remove_selftransitions` removes the transitions from each state to
itself.

## Examples

``` r
data("EMMTraffic")
emm <- EMM(measure="eJaccard", threshold=0.2)
emm <- build(emm, EMMTraffic)

## remove state 3
emm_rs3 <- remove_clusters(emm, "3")

## remove transition 5->2
emm_rt52 <- remove_transitions(emm, "5", "2")

## compare EMMs
op <- par(mfrow = c(2, 2), pty = "m")
plot(emm, method = "igraph", main = "original EMM")
plot(emm_rs3, method = "igraph", main = "state 3 removed")
plot(emm_rt52, method = "igraph", main = "transition 5->2 removed")
par(op)
```
