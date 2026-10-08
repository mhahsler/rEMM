# Derwent Catchment Data

Data set with flow readings (in cubic meter per second) for six
catchments of in the vicinity of the Derwent river in the northern UK.
The data was collected daily from November 1, 1971 – January 31, 1977.
The catchments are Long Bridge, Matlock Bath, Chat Sworth, What Stand
Well, Ashford (Wye) and Wind Field Park (Amber).

The owner of the data is the Ridings Area Office of the Environment
Agency North-East, UK.

## Usage

``` r
data(Derwent)
```

## Format

A matrix of size 1918 days times 6 catchments.

## Source

UK National River Flow Archive (NRFA), <https://nrfa.ceh.ac.uk/>

The owner of the data is the Ridings Area Office of the Environment
Agency North-East, UK.

## References

Wikipedia, River Derwent, Yorkshire,
<https://en.wikipedia.org/wiki/River_Derwent,_Yorkshire>

Wikipedia, River Wye, Derbyshire,
<https://en.wikipedia.org/wiki/River_Wye,_Derbyshire>

Wikipedia, River Amber, <https://en.wikipedia.org/wiki/River_Amber>

## Examples

``` r
data(Derwent)

i <- 1
plot(Derwent[,i], type="l", main=colnames(Derwent[i]), ylab="Gauged Flows")
```
