# Class "TRACDS"

Representation of the temporal structure of a data stream clustering
using a extensible Markov model.

## Usage

``` r
TRACDS(lambda = 0)

as.igraph(object)

# S3 method for class 'TRACDS'
as.igraph(object)

as.graph(object)

# S3 method for class 'TRACDS'
as.graph(object)
```

## Arguments

- lambda:

  Numeric fading rate. Zero disables fading.

- object:

  A `TRACDS` or `EMM` object.

## Value

An object of class `"TRACDS"`.

## Note

A TRACDS object can be coerced to igraph or graph objects using
`as.igraph`() and `as.graph()`.

## Objects from the Class

Objects can be created using the creator function `TRACDS` or by
directly calling `new("TRACDS", ...)`. Most slots for the extended
classes can be used as parameters.

## Slots

- `lambda`::

  Object of class `"numeric"` specifying the rate for fading.

- `lambda_factor`::

  Object of class `"numeric"` expressing the fading rate expressed as a
  factor.

- `tracds_d`::

  An environment containing all the variable data of the TRACDS object:

  `mm`:

  :   Object of class `"SimpleMC"` representing the first order Markov
      model of the EMM.

  `current_state`:

  :   Object of class `"character"` with the name of current state in
      the EMM. `NA` means no current state.

## Methods

- copy:

  `signature(x = "TRACDS")`: Make a copy of the TRACDS object. Making
  explicit copies is necessary since information is stored in an
  environment which is not copied for regular assignements.

- current_state:

  `signature(x = "TRACDS")`: returns the name of the current state.

- nstates:

  `signature(x = "TRACDS")`: returns the number of states.

- ntransitions:

  `signature(x = "TRACDS")`: returns the number of transitions with a
  count larger than 0 stored in the object.

- plot:

  `signature(x = "TRACDS", y = "missing")`: Plots the object as a
  directed graph.

- states:

  `signature(x = "TRACDS")`: returns the names of the states.

- transitions:

  `signature(x = "TRACDS")`: returns all transitions as a matrix of
  state names with a from and a to column.

## References

Michael Hahsler and Margaret H. Dunham. Temporal structure learning for
clustering massive data streams in real-time. In *SIAM Conference on
Data Mining* (SDM11), pages 664–675. SIAM, April 2011.
[doi:10.1137/1.9781611972818.57](https://doi.org/10.1137/1.9781611972818.57)

M. Hahsler, M. H. Dunham (2010): rEMM: Extensible Markov Model for Data
Stream Clustering in R, *Journal of Statistical Software,* 35(5), 1-31,
URL [doi:10.18637/jss.v035.i05](https://doi.org/10.18637/jss.v035.i05)

M.H. Dunham, Y. Meng, J. Huang (2004): Extensible Markov Model, In:
*ICDM '04: Proceedings of the Fourth IEEE International Conference on
Data Mining,* pp. 371–374.

## See also

Look at
[`transition`](http://michael.hahsler.net/rEMM/reference/transition.md),
[`transition_matrix`](http://michael.hahsler.net/rEMM/reference/transition.md)
and
[`initial_transition`](http://michael.hahsler.net/rEMM/reference/transition.md)
to access the transition information in the EMM.
[`predict`](http://michael.hahsler.net/rEMM/reference/predict.md) is
used to predict future states of an EMM.
[`EMM`](http://michael.hahsler.net/rEMM/reference/EMM-class.md) extends
`"TRACDS"`.
