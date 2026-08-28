# Groups Where a Swap Can Still Be Proposed

A group can only be rearranged if it holds two exchangeable treatments.
Whether it does is fixed for the whole of a level, because a level's
swaps permute treatments within a group and so change neither the number
of distinct treatments nor their replication counts. It is therefore
settled once per level rather than rediscovered by sampling.

## Usage

``` r
swappable_groups(design, swap, swap_within, swap_all)
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

- swap_all:

  Whether to swap all matching items or a single item at a time
  (default: FALSE)

## Value

A list with:

- **swappable** - groups holding an exchangeable pair.

- **unequal_replication** - groups where `swap_all = TRUE` rules out
  every pair, because no two treatments there share a replication count.
  Kept separate from the rest of the unswappable groups because, unlike
  a group holding a single treatment, it is rarely what was intended.
