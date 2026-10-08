# Hypothetical Traffic Data Set for EMM

Each observation in this hypothetical data set is a vector of seven
values obtained from sensors located at specific points on roads. Each
sensor collects a count of the number of vehicles which have crossed
this sensor in the preceding time interval.

## Usage

``` r
data(EMMTraffic)
```

## Format

A matrix with 12 observations (rows).

## References

M.H. Dunham, Y. Meng, J. Huang (2004): Extensible Markov Model, In:
*ICDM '04: Proceedings of the Fourth IEEE International Conference on
Data Mining,* pp. 371–374.

## Examples

``` r
data(EMMTraffic)
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
```
