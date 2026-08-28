# Verify Inputs Needing the Resolved `optimise` List

Checks that can only run once
[`create_speed_input()`](https://biometryhub.github.io/speed/reference/create_speed_input.md)
has merged the three input shapes into one per-level list, either
because their rules are cross-level or because they must cover all three
shapes alike.
[`speed()`](https://biometryhub.github.io/speed/reference/speed.md)
calls them after
[`create_speed_input()`](https://biometryhub.github.io/speed/reference/create_speed_input.md),
not from
[`.verify_inputs()`](https://biometryhub.github.io/speed/reference/verify.md).

`.verify_level_columns()` catches a level naming a column that is not
there, which the `optimise` shape would otherwise carry into the search
unchallenged: a bad `swap_within` leaves
[`swappable_groups()`](https://biometryhub.github.io/speed/reference/swappable_groups.md)
with nothing to group by, and the level is reported as frozen rather
than as a mistake.

Checks the columns named in `linked_cols` after they have been merged
into the per-level `optimise` list, so all three input shapes are
covered by one set of rules.

`swap_all = TRUE` proposes a move by exchanging *every* plot holding one
treatment with *every* plot holding another. That is a rearrangement of
the design only when both treatments occupy the same number of plots
within the swap group; when they do not, the two treatments exchange
replication counts and the design that comes back is not the design that
went in. Error before any optimisation happens rather than silently
altering replication.

Called on the resolved `optimise` list, so it covers simple, legacy
hierarchical and `optimise = ` calls alike, including levels that set
`swap_all` individually.

## Usage

``` r
.verify_level_columns(data, optimise)

.verify_linked_cols(data, optimise, linked_cols = NULL, named_levels = TRUE)

.verify_swap_all_replication(data, optimise, dummy_group = NULL)
```

## Arguments

- data:

  A data frame containing the experimental design with spatial
  coordinates

- optimise:

  The resolved per-level list built by
  [`create_speed_input()`](https://biometryhub.github.io/speed/reference/create_speed_input.md).

- linked_cols:

  Character vector of column names that travel with the `swap` column,
  for example a `variety_name` label belonging to a numeric `variety`
  code (default: `NULL`). For hierarchical designs, can be a named list
  with names matching `swap`. See details for more information.

- named_levels:

  Whether the level names are the user's own. `FALSE` for a scalar
  `swap` with no `optimise`, whose single level name is synthesised, so
  no error may quote it back at them.

- dummy_group:

  Name of the internal placeholder column used for a level with no
  `swap_within` boundary, so it can be described as the whole design.
