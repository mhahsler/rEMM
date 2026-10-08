# Class "tNN"

Implements the threshold Nearest Neighbor clustering algorithm used by
EMM.

## Usage

``` r
tNN(
  threshold = 0.2,
  measure = "euclidean",
  centroids = identical(tolower(measure), "euclidean"),
  lambda = 0
)
```

## Arguments

- threshold:

  Numeric dissimilarity threshold for assigning new observations to
  existing clusters.

- measure:

  Name of the dissimilarity measure; see `dist`.

- centroids:

  Logical; use centroids if `TRUE`, otherwise represent clusters by
  their first observation.

- lambda:

  Numeric fading rate. Zero disables fading.

## Value

An object of class `"tNN"`.

## Objects from the Class

Objects can be created with `new()` or by the creator function `tNN`.

## Slots

- `measure`::

  Object of class `"character"` containing the name of the dissimilarity
  measure used (see `dist` in proxy for available measures)

- `centroids`::

  Object of class `"logical"` indicating if centroids are used for
  clusters. If `FALSE`, pseudo medians (first observation of a cluster)
  are used to represent a cluster.

- `threshold`::

  Object of class `"numeric"` with the dissimilarity threshold used by
  the NN clustering algorithm for assigning a new observation to
  existing clusters.

- `lambda`::

  Object of class `"numeric"` specifying the rate for fading.

- `lambda_factor`::

  Object of class `"numeric"` expressing the fading rate expressed as a
  factor.

- `tnn_d`::

  An environment containing the variable data for the tNN object:

  `centers`:

  :   Object of class `"matrix"` containing the cluster centers.

  `counts`:

  :   Object of class `"numeric"` with the number of observations
      assigned to each cluster.

  `var_thresholds`:

  :   Object of class `"numeric"` with the dissimilarity thresholds for
      individual clusters (usually the same as threshold).

  `last`:

  :   A `"character"` vector containing the cluster names the points for
      the previous call of
      [`cluster()`](http://michael.hahsler.net/rEMM/reference/cluster.md)
      were assigned to.

## Methods

- copy:

  `signature(x = "tNN")`: Make a copy of the tNN object. Making explicit
  copies is necessary since information is stored in an environment
  which is not copied for regular assignements.

- cluster_centers:

  `signature(x = "tNN")`: returns the cluster centers as a matrix.

- cluster_counts:

  `signature(x = "tNN")`: returns the cluster counts as a vector.

- clusters:

  `signature(x = "tNN")`: returns the names of the clusters.

- last_clustering:

  `signature(x = "tNN")`: returns the indices of the clusters the data
  points in the last cluster operation where assigned to. To save memory
  the last clustering information can be removed by setting the formal
  parameter `remove` to `TRUE`.

- nclusters:

  `signature(x = "tNN")`: returns the number of clusters in the
  clustering.

- plot:

  `signature(x = "tNN", y = "missing")`: plots the cluster centers using
  a scatterplot matrix (see `pairs`).

## References

M.H. Dunham, Y. Meng, J. Huang (2004): Extensible Markov Model, In:
*ICDM '04: Proceedings of the Fourth IEEE International Conference on
Data Mining,* pp. 371–374.

## See also

[`cluster`](http://michael.hahsler.net/rEMM/reference/cluster.md) for
adding new data to the clustering.
[`find_clusters`](http://michael.hahsler.net/rEMM/reference/find_clusters.md)
to find the nearest neighbor cluster for given data points.
[`EMM`](http://michael.hahsler.net/rEMM/reference/EMM-class.md) extends
"tNN".
