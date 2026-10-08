# Extract a Transition Table for a New Sequence Given an EMM

Finds the state sequence of a new sequence in an EMM and returns a table
with the transition probabilities or counts.

## Usage

``` r
# S4 method for class 'EMM,matrix'
transition_table(
  x,
  newdata,
  type = c("probability", "counts", "log_odds"),
  match_cluster = "exact",
  prior = TRUE,
  initial_transition = FALSE
)
```

## Arguments

- x:

  an `EMM` object.

- newdata:

  new sequence,

- type:

  the measure to return.

- match_cluster:

  do the new observations have to fall within the threshold of the
  cluster (`"exact"`) or is nearest neighbor used (`"nn"`)?

- prior:

  add one to each transition count. This is equal to starting with a
  uniform prior for the transition count distribution, i.e. initially
  all transitions are equally likely. It also prevents the product of
  probabilities to be zero if a transition was never observed.

- initial_transition:

  include the initial transition in the table?

## Value

A data.frame with three columns (from state, to state and the transition
probability/count.)

## See also

[`transition`](http://michael.hahsler.net/rEMM/reference/transition.md)
to access transition probabilities and
[`find_clusters`](http://michael.hahsler.net/rEMM/reference/find_clusters.md)
for assigning observations to states/clusters.

## Examples

``` r
data("EMMsim")

emm <- EMM(threshold=.5)
emm <- build(emm, EMMsim_train)

head(transition_table(emm, EMMsim_test))
#>   from to probability
#> 1    5  2  0.44444444
#> 2    2  1  0.88888889
#> 3    1  3  0.49382716
#> 4    3  4  0.91111111
#> 5    4  5  0.09090909
#> 6    5  2  0.44444444
head(transition_table(emm, EMMsim_test, type ="prob", initial_transition=TRUE))
#>   from to probability
#> 1 <NA>  5  0.16666667
#> 2    5  2  0.44444444
#> 3    2  1  0.88888889
#> 4    1  3  0.49382716
#> 5    3  4  0.91111111
#> 6    4  5  0.09090909
```
