# Warn About Groups No `swap_all` Swap Can Reach

Reported per level rather than up front, because
[`.verify_swap_all_replication()`](https://biometryhub.github.io/speed/reference/verify_resolved.md)
has already errored on unequal replication at the first level. This can
only arise where an earlier level's swaps have unbalanced a group
cutting across theirs.

## Usage

``` r
.warn_unequal_replication(unequal, level, swap_within)
```

## Arguments

- unequal:

  Group names, as returned in the `unequal_replication` element of
  [`swappable_groups()`](https://biometryhub.github.io/speed/reference/swappable_groups.md).

- level:

  Name of the level being optimised.

- swap_within:

  Column name grouping the swaps at that level.

## Value

`NULL`, invisibly.
