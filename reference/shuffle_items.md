# Shuffle Items in A Group

Shuffle Items in A Group

## Usage

``` r
shuffle_items(design, swap, swap_within, seed = NULL, linked_cols = NULL)
```

## Arguments

- design:

  Data frame containing the current design

- swap:

  Column name of the treatment to swap, or named list for hierarchical
  designs

- swap_within:

  Column name defining groups within which to swap treatments, or named
  list for hierarchical designs

- seed:

  A numeric value for random seed. If provided, it ensures
  reproducibility of results (default: `NULL`).

- linked_cols:

  Character vector of column names moved in lockstep with the `swap`
  column, so that a value paired with a treatment stays paired with it.
  `NULL` (default) moves the `swap` column alone.

## Value

A data frame with the items shuffled
