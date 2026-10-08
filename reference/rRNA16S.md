# Count Data for 16S rRNA Sequences

This data set contains count data for 16S ribosomal RNA (rRNA) sequences
for the two phylogenetic classes Alphaproteobacteria and Mollicutes. The
counts for 30 sequences for each class were obtained by counting the
occurrence of triplets of nucleotides in windows of length 100 without
any overlap. To separate sequences a row of dummy count of `NA` is used.

## Usage

``` r
data("16S")
```

## Format

`Alphaproteobacteria16S` and `Mollicutes16S` are matrices with about 449
rows and 64 (number of possible triplets) columns.

## Source

The raw sequence information was obtained from the National center for
biotechnology information (NCBI) website at http://www.ncbi.nih.gov/

## Examples

``` r
data("16S")

emm_mollicutes <- EMM("Kullback", threshold=0.1)
emm_alphaproteobacteria <- EMM("Kullback", threshold=0.1)

# build with an added count of 1 for count smoothing
build(emm_mollicutes, Mollicutes16S + 1)
build(emm_alphaproteobacteria, Alphaproteobacteria16S + 1)

plot(emm_mollicutes)

plot(emm_alphaproteobacteria)
```
