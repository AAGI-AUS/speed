# Shuffle Items in A Group

A shuffle has to move what the search moves, or it starts the search
from a design the search itself could never reach. `swap_all` exchanges
whole sets of like-treatment plots, so it shuffles treatment labels
between those sets; a single swap exchanges plots, so it shuffles the
plots.

## Usage

``` r
shuffle_items(
  design,
  swap,
  groups,
  seed = NULL,
  linked_cols = NULL,
  swap_all = FALSE
)
```

## Arguments

- design:

  Data frame containing the current design

- swap:

  Column name of the treatment to swap, or named list for hierarchical
  designs

- groups:

  Factor giving the group each plot is shuffled within.

- seed:

  A numeric value for random seed. If provided, it ensures
  reproducibility of results (default: `NULL`).

- linked_cols:

  Character vector of column names moved in lockstep with the `swap`
  column, so that a value paired with a treatment stays paired with it.
  `NULL` (default) moves the `swap` column alone.

- swap_all:

  Whether to swap all matching items or a single item at a time
  (default: FALSE)

## Value

A data frame with the items shuffled
