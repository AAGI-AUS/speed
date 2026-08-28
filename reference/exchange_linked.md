# Exchange Linked Columns Between Two Sets of Plots

Moves each `linked_cols` column between `plots_1` and `plots_2` position
by position, so a value paired with a treatment follows it. The two sets
are always the same length: trivially so for a single swap, and for
`swap_all` because only treatments of equal replication are exchanged.

## Usage

``` r
exchange_linked(design, linked_cols, plots_1, plots_2)
```

## Arguments

- design:

  Data frame containing the current design

- linked_cols:

  Character vector of column names to exchange

- plots_1, plots_2:

  Equal-length vectors of row positions

## Value

`design`, with the linked columns exchanged
