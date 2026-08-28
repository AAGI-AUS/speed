# Columns a Single Level Treats as Fixed Layout

The columns that say where a plot sits and which group it belongs to.
Unlike the `swap` column these never move, so they can be neither
optimised by another level nor linked to one.

## Usage

``` r
.level_fixed_cols(opt)
```

## Arguments

- opt:

  One level of the `optimise` list.

## Value

A character vector of column names.
