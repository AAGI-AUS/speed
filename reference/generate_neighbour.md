# Generate a Neighbour Design by Swapping Treatments

Generate a Neighbour Design by Swapping Treatments

## Usage

``` r
generate_neighbour(
  design,
  swap,
  swap_within,
  swap_count = getOption("speed.swap_count", 1),
  swap_all_blocks = getOption("speed.swap_all_blocks", FALSE),
  swap_all = FALSE,
  linked_cols = NULL,
  swappable = NULL
)
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

- swap_count:

  Number of swaps to perform

- swap_all_blocks:

  Whether to perform swaps in all blocks or just one

- swap_all:

  Whether to swap all matching items or a single item at a time
  (default: FALSE)

- linked_cols:

  Character vector of column names moved in lockstep with the `swap`
  column, so that a value paired with a treatment stays paired with it.
  `NULL` (default) moves the `swap` column alone.

- swappable:

  Groups a swap can be proposed in, as returned in the `swappable`
  element of
  [`swappable_groups()`](https://biometryhub.github.io/speed/reference/swappable_groups.md).
  `NULL` (default) considers every group, which costs an iteration
  whenever an unswappable one is drawn.

## Value

A list with the updated design after swapping and information about
swapped items
