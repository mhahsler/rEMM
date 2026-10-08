# Predict a Future State

Predict a state or the probability distribution over states in \\n\\
time steps.

## Usage

``` r
# S4 method for class 'TRACDS'
predict(
  object,
  current_state = NULL,
  n = 1,
  probabilities = FALSE,
  randomized = FALSE,
  prior = FALSE
)
```

## Arguments

- object:

  an `"EMM"`/`"TRACDS"` object.

- current_state:

  use a specified current state. If `NULL`, the EMM's current state is
  used.

- n:

  number of time steps.

- probabilities:

  if `TRUE`, instead of the predicted state, the probability
  distribution is returned.

- randomized:

  if `TRUE`, the predicted state is choosen randomly with a selection
  probability proportional to its transition probability

- prior:

  add one to each transition count. This is equal to starting with a
  uniform prior for the transition count distribution, i.e. initially
  all transitions are equally likely. It also prevents the product of
  probabilities to be zero if a transition was never observed.

## Value

The name of the predicted state or a vector with the probability
distribution over all states.

## Details

Prediction is done using \\A^n\\ where \\A\\ is the transition
probability matrix maintained by the EMM. Random tie-breaking is used.

## See also

[`transition_matrix`](http://michael.hahsler.net/rEMM/reference/transition.md)

## Examples

``` r
data("EMMTraffic")
emm <- EMM(measure="eJaccard", threshold=0.2)
emm <- build(emm, EMMTraffic)

#plot(emm) ## plot graph

## Predict state starting an state 1 after 1, 2 and 100 time intervals
## Note, state 7 is an absorbing state.
predict(emm, n=1, current_state="1")
#> [1] "2"
predict(emm, n=2, current_state="1")
#> [1] "3"
predict(emm, n=100, current_state="1")
#> [1] "7"

## Get probability distribution
predict(emm, n=2, current_state="1", probabilities = TRUE)
#>         1         2         3         4         5         6         7 
#> 0.3333333 0.0000000 0.3333333 0.0000000 0.0000000 0.3333333 0.0000000 
```
