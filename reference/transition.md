# Access Transition Probabilities/Counts in an EMM

Calculates individual transition probabilities/counts or a complete
transition matrix for an EMM (which contains `"TRACDS"`).

## Usage

``` r
# S4 method for class 'TRACDS,character,character'
transition(
  x,
  from,
  to,
  type = c("probability", "counts", "log_odds"),
  prior = TRUE
)

# S4 method for class 'TRACDS'
transition_matrix(
  x,
  type = c("probability", "counts", "log_odds"),
  prior = TRUE
)

# S4 method for class 'TRACDS'
initial_transition(
  x,
  type = c("probability", "counts", "log_odds"),
  prior = TRUE
)
```

## Arguments

- x:

  an object of class `"EMM"`/`"TRACDS"`.

- from, to:

  Names a states. If `to` is missing, `from` has to contain a matrix
  with two columns (a from column and a to column as returned by
  `transitions`).

- type:

  What should be calculated?

- prior:

  add one to each transition count. This is equal to starting with a
  uniform prior for the transition count distribution, i.e., initially
  all transitions are equally likely.

## Value

A scalar (for `transition`), a square matrix (for `transition_matrix`)
or a vector (for `initial_transition`).

## Details

Log odds are calculated as \\ln(a/(1/n))\\ where \\a\\ is the
probability of the transition and \\n\\ is the number of states in the
EMM. \\1/n\\ is the probability of a transition under the null model
which assumes that the transition probability from each state to each
other state (including staying in the same state) is the same, i.e., the
null model has a transition matrix with all entries equal to \\1/n\\.

## See also

[`EMM`](http://michael.hahsler.net/rEMM/reference/EMM-class.md) which
contains
[`TRACDS`](http://michael.hahsler.net/rEMM/reference/TRACDS-class.md)

## Examples

``` r
data("EMMTraffic")
emm <- EMM(measure="eJaccard", threshold=0.2)
emm <- build(emm, EMMTraffic)

## get transition matrix
transition_matrix(emm, type="count", prior=FALSE)
#>   1 2 3 4 5 6 7
#> 1 0 2 0 0 0 0 0
#> 2 1 0 1 0 0 1 0
#> 3 0 0 0 1 0 0 0
#> 4 0 0 0 0 2 0 0
#> 5 0 1 0 0 0 0 1
#> 6 0 0 0 1 0 0 0
#> 7 0 0 0 0 0 0 0
transition_matrix(emm, type="count")
#>   1 2 3 4 5 6 7
#> 1 1 3 1 1 1 1 1
#> 2 2 1 2 1 1 2 1
#> 3 1 1 1 2 1 1 1
#> 4 1 1 1 1 3 1 1
#> 5 1 2 1 1 1 1 2
#> 6 1 1 1 2 1 1 1
#> 7 1 1 1 1 1 1 1
transition_matrix(emm, prior=FALSE)
#>           1   2         3 4 5         6   7
#> 1 0.0000000 1.0 0.0000000 0 0 0.0000000 0.0
#> 2 0.3333333 0.0 0.3333333 0 0 0.3333333 0.0
#> 3 0.0000000 0.0 0.0000000 1 0 0.0000000 0.0
#> 4 0.0000000 0.0 0.0000000 0 1 0.0000000 0.0
#> 5 0.0000000 0.5 0.0000000 0 0 0.0000000 0.5
#> 6 0.0000000 0.0 0.0000000 1 0 0.0000000 0.0
#> 7 0.0000000 0.0 0.0000000 0 0 0.0000000 1.0
transition_matrix(emm)
#>           1         2         3         4         5         6         7
#> 1 0.1111111 0.3333333 0.1111111 0.1111111 0.1111111 0.1111111 0.1111111
#> 2 0.2000000 0.1000000 0.2000000 0.1000000 0.1000000 0.2000000 0.1000000
#> 3 0.1250000 0.1250000 0.1250000 0.2500000 0.1250000 0.1250000 0.1250000
#> 4 0.1111111 0.1111111 0.1111111 0.1111111 0.3333333 0.1111111 0.1111111
#> 5 0.1111111 0.2222222 0.1111111 0.1111111 0.1111111 0.1111111 0.2222222
#> 6 0.1250000 0.1250000 0.1250000 0.2500000 0.1250000 0.1250000 0.1250000
#> 7 0.1428571 0.1428571 0.1428571 0.1428571 0.1428571 0.1428571 0.1428571

## get initial state probabilities
initial_transition(emm)
#>     1     2     3     4     5     6     7 
#> 0.250 0.125 0.125 0.125 0.125 0.125 0.125 

## access individual transition probability (state 1 -> 2)
transition(emm, "1","2")
#> [1] 0.3333333

## get counts for all existing transitions
tr <- transitions(emm)
tr
#>       from to 
#>  [1,] "2"  "1"
#>  [2,] "1"  "2"
#>  [3,] "5"  "2"
#>  [4,] "2"  "3"
#>  [5,] "3"  "4"
#>  [6,] "6"  "4"
#>  [7,] "4"  "5"
#>  [8,] "2"  "6"
#>  [9,] "5"  "7"
cbind(as.data.frame(tr), counts=transition(emm, tr, type="counts"))
#>   from to counts
#> 1    2  1      2
#> 2    1  2      3
#> 3    5  2      2
#> 4    2  3      2
#> 5    3  4      2
#> 6    6  4      2
#> 7    4  5      3
#> 8    2  6      2
#> 9    5  7      2
```
