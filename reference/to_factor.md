# Convert Data Frame Data to Factors

Converts the named columns to factors. Names not present in `df` are
ignored, so a caller may pass the `"1"` / `"none"` placeholder used for
a level with no `swap_within` boundary. Columns outside `cols` are left
untouched.

## Usage

``` r
to_factor(df, cols = names(df))
```

## Arguments

- df:

  A data frame

- cols:

  Names of the columns to convert (default: every column).

## Value

A list containing:

- **df** - A data frame with the named columns as factors

- **input_types** - A named character vector of the original base type
  of each converted column (for restoring via
  [`to_types()`](https://biometryhub.github.io/speed/reference/to_types.md))
