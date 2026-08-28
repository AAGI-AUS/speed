# Convert Data Frame Data to Factors

Converts the named columns to factors, which is what the SA loop
requires. Names not present in `df` are ignored, so a caller may pass
the `"1"` / `"none"` placeholder used for a level with no `swap_within`
boundary. Columns outside `cols` are left untouched and are not recorded
in `input_types`, so
[`to_types()`](https://biometryhub.github.io/speed/reference/to_types.md)
returns them exactly as they came in - the only way to preserve a class
[`base_type()`](https://biometryhub.github.io/speed/reference/base_type.md)
cannot rebuild, such as `Date`.

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
