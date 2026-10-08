# Update a TRACDS temporal structure with new state assignements

Add a sequence of new state assignments to a TRACDS object.

## Usage

``` r
# S4 method for class 'TRACDS'
compact(x)

# S4 method for class 'TRACDS'
reset(x)

# S4 method for class 'TRACDS'
update(object, newdata, verbose = FALSE, ...)
```

## Arguments

- x, object:

  a `TRACDS` object. Note that this function changes the original
  object!

- newdata:

  a vector with a state assignemnt sequence (typically produced by
  clustering).

- verbose:

  logical; verbose output?

- ...:

  further arguments.

## Value

A reference to the changed TRACDS object with the data added. Note: EMM
objects store all variable data in an environment which enables us to
update partial data without copying the whole object. Assignment will
not create a copy! Use the provided method
[`copy()`](http://michael.hahsler.net/rEMM/reference/EMM-class.md).

## Details

`update()` adds a new state assignemnt sequenc to the TRACDS object by
increasing the transition counts and, if needed, creating new states.

`reset()` resets the current state to `NA` for reading in a new
sequence. An `NA` in `newdata` also resets the current state.

`compact()` reduces the size (memory) used to store the temporal
transition matrix.

## See also

Class
[`TRACDS`](http://michael.hahsler.net/rEMM/reference/TRACDS-class.md),
[`fade`](http://michael.hahsler.net/rEMM/reference/fade.md).

## Examples

``` r
## create an empty TRACDS object
tracds <- TRACDS()
tracds
#> tNN with 0 states.

## update with an cluster assignment sequence
update(tracds, c(1,2,5,5,2))
tracds
#> tNN with 3 states.

plot(tracds)
```
