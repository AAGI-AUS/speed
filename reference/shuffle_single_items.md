# Shuffle one plot at a time within each group

Shuffle one plot at a time within each group

## Usage

``` r
shuffle_single_items(design, swap, groups, linked_cols, movable)
```

## Arguments

- design:

  Data frame containing the current design

- swap:

  Column name of the treatment to swap, or named list for hierarchical
  designs

- groups:

  Factor giving the group each plot is shuffled within.

- linked_cols:

  Character vector of column names moved in lockstep with the `swap`
  column, so that a value paired with a treatment stays paired with it.
  `NULL` (default) moves the `swap` column alone.

- movable:

  Logical vector marking the plots free to move.
