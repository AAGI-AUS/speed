# `speed()` over particular field layouts - large, blocked, irregular and
# unevenly replicated designs.

test_that("speed handles irregular layouts with missing plots", {
  irregular_data <- data.frame(
    row = rep(1:4, each = 3),
    col = rep(1:3, times = 4),
    treatment = rep(LETTERS[1:3], 4)
  )

  irregular_data$treatment[c(1, 9, 11)] <- NA

  result <- speed(
    data = irregular_data,
    swap = "treatment",
    spatial_factors = ~ row + col,
    iterations = 2000,
    seed = 42,
    quiet = TRUE
  )
  expect_s3_class(result, "design")

  expect_identical(
    which(is.na(result$design_df$treatment)),
    which(is.na(irregular_data$treatment))
  )

  expect_equal(result$score, 1)

  vdiffr::expect_doppelganger("speed_missing_plots", autoplot(result))
})

test_that("random initialisation leaves missing plots where they are", {
  irregular_data <- data.frame(
    row = rep(1:4, each = 3),
    col = rep(1:3, times = 4),
    block = rep(1:2, each = 6),
    treatment = rep(LETTERS[1:3], 4)
  )

  irregular_data$treatment[c(1, 9, 11)] <- NA

  result <- speed(
    data = irregular_data,
    swap = "treatment",
    swap_within = "block",
    spatial_factors = ~ row + col,
    iterations = 100,
    optimise_params = optim_params(random_initialisation = 5),
    seed = 42,
    quiet = TRUE
  )

  # The shuffle permutes treatments, not plots, so a plot holding no treatment
  # keeps holding none
  expect_identical(
    which(is.na(result$design_df$treatment)),
    which(is.na(irregular_data$treatment))
  )
  expect_equal(
    sort(result$design_df$treatment),
    sort(irregular_data$treatment)
  )
})

test_that("random initialisation holds a plot missing at any level", {
  # `sp` is missing on the plots of one wholeplot, `wp` on the plots of another
  split_data <- data.frame(
    row = rep(1:12, each = 4),
    col = rep(1:4, times = 12),
    block = rep(1:4, each = 12),
    wholeplot = rep(1:12, each = 4),
    wholeplot_treatment = rep(rep(LETTERS[1:3], each = 4), times = 4),
    subplot_treatment = rep(letters[1:4], 12)
  )
  split_data$subplot_treatment[split_data$wholeplot == 2] <- NA
  split_data$wholeplot_treatment[split_data$wholeplot == 7] <- NA

  result <- speed(
    split_data,
    swap = list(wp = "wholeplot_treatment", sp = "subplot_treatment"),
    swap_within = list(wp = "block", sp = "wholeplot"),
    iterations = 100,
    optimise_params = optim_params(random_initialisation = 5),
    seed = 42,
    quiet = TRUE
  )

  for (column in c("wholeplot_treatment", "subplot_treatment")) {
    expect_identical(
      which(is.na(result$design_df[[column]])),
      which(is.na(split_data[[column]]))
    )
  }
})

test_that("random initialisation keeps a swap_all design's units whole", {
  split_data <- data.frame(
    row = rep(1:12, each = 4),
    col = rep(1:4, times = 12),
    block = rep(1:4, each = 12),
    wholeplot = rep(1:12, each = 4),
    wholeplot_treatment = rep(rep(LETTERS[1:3], each = 4), times = 4),
    subplot_treatment = rep(letters[1:4], 12)
  )

  result <- speed(
    split_data,
    swap = list(wp = "wholeplot_treatment", sp = "subplot_treatment"),
    swap_within = list(wp = "block", sp = "wholeplot"),
    swap_all = TRUE,
    iterations = 200,
    optimise_params = optim_params(random_initialisation = 5),
    seed = 42,
    quiet = TRUE
  )
  design_df <- result$design_df

  # `swap_all` moves whole sets of like-treatment plots, so every wholeplot
  # still holds one wholeplot treatment across all four of its plots
  per_wholeplot <- tapply(
    as.character(design_df$wholeplot_treatment),
    design_df$wholeplot,
    function(x) return(length(unique(x)))
  )
  expect_true(all(per_wholeplot == 1))

  # The treatment set of each block, and of the design, is unchanged
  expect_equal(
    table(design_df$block, design_df$wholeplot_treatment),
    table(split_data$block, split_data$wholeplot_treatment)
  )

  # The shuffle still moves something, rather than passing the design through
  expect_false(identical(
    as.character(design_df$wholeplot_treatment),
    as.character(split_data$wholeplot_treatment)
  ))
})

test_that("random initialisation keeps swap_all strips whole", {
  df_strip <- data.frame(
    row = rep(1:12, each = 6),
    col = rep(1:6, times = 12),
    block = rep(rep(1:2, each = 3), times = 4) + rep(0:2 * 2, each = 24),
    vertical_treatment = rep(rep(LETTERS[1:3], times = 2), times = 12),
    horizontal_treatment = rep(rep(letters[1:4], each = 6), times = 3)
  )

  result <- speed(
    df_strip,
    swap = list(ht = "horizontal_treatment", vt = "vertical_treatment"),
    swap_within = list(ht = "block", vt = "block"),
    swap_all = TRUE,
    iterations = list(ht = 100, vt = 100),
    optimise_params = optim_params(random_initialisation = 5),
    seed = 42,
    quiet = TRUE
  )
  design_df <- result$design_df

  # A strip runs the width of its block, so each holds a single treatment
  strips <- list(
    vertical_treatment = paste(design_df$block, design_df$col),
    horizontal_treatment = paste(design_df$block, design_df$row)
  )
  for (column in names(strips)) {
    per_strip <- tapply(
      as.character(design_df[[column]]),
      strips[[column]],
      function(x) return(length(unique(x)))
    )
    expect_true(all(per_strip == 1))
  }
})

test_that("random initialisation keeps linked_cols paired under swap_all", {
  split_data <- data.frame(
    row = rep(1:12, each = 4),
    col = rep(1:4, times = 12),
    block = rep(1:4, each = 12),
    wholeplot = rep(1:12, each = 4),
    wholeplot_treatment = rep(rep(LETTERS[1:3], each = 4), times = 4)
  )
  split_data$wholeplot_name <- paste0(
    "trt-",
    tolower(split_data$wholeplot_treatment)
  )

  result <- speed(
    split_data,
    swap = "wholeplot_treatment",
    swap_within = "block",
    linked_cols = "wholeplot_name",
    swap_all = TRUE,
    iterations = 200,
    optimise_params = optim_params(random_initialisation = 5),
    seed = 42,
    quiet = TRUE
  )

  # One name per treatment, and the same one it started with. A label moved
  # without its linked column would show up as an extra pair here.
  pairing <- function(design_df) {
    pairs <- unique(data.frame(
      treatment = as.character(design_df$wholeplot_treatment),
      name = as.character(design_df$wholeplot_name)
    ))
    return(pairs[order(pairs$treatment), ])
  }

  expect_equal(
    pairing(result$design_df),
    pairing(split_data),
    ignore_attr = "row.names"
  )
})

test_that("speed handles multiple spatial factors", {
  multi_factor_data <- data.frame(
    row = rep(1:5, each = 5),
    col = rep(1:5, times = 5),
    block = rep(1:5, each = 5),
    treatment = rep(LETTERS[1:5], 5)
  )
  result <- speed(
    data = multi_factor_data,
    swap = "treatment",
    swap_within = "block",
    spatial_factors = ~ row + col + block,
    iterations = 10000,
    seed = 42,
    quiet = TRUE
  )
  expect_s3_class(result, "design")

  vdiffr::expect_doppelganger("speed_multi_spatial_factors", autoplot(result))
})

test_that("speed handles non-uniform treatment distributions", {
  non_uniform_data <- data.frame(
    row = rep(1:8, each = 9),
    col = rep(1:9, times = 8),
    treatment = c(rep(LETTERS[1], 27), rep(LETTERS[2:6], 9))
  )
  result <- speed(
    data = non_uniform_data,
    swap = "treatment",
    spatial_factors = ~ row + col,
    iterations = 20000,
    early_stop_iterations = 5000,
    seed = 42,
    quiet = TRUE
  )
  expect_s3_class(result, "design")

  expect_equal(result$stopped_early, TRUE)

  expect_equal(result$score, 14)
  expect_equal(result$iterations_run, 13264)

  vdiffr::expect_doppelganger("speed_non_uniform", autoplot(result))
})

test_that("speed works with a custom objective function", {
  custom_obj_function <- function(adj_weight = 0.5, bal_weight = 2) {
    function(design, swap, spatial_cols, ...) {
      adj_score <- calculate_adjacency_score(design, swap)
      bal_score <- calculate_balance_score(design, swap, spatial_cols)
      return(list(score = adj_weight * adj_score + bal_weight * bal_score))
    }
  }
  custom_obj_data <- data.frame(
    row = rep(1:4, each = 4),
    col = rep(1:4, times = 4),
    treatment = rep(LETTERS[1:4], 4)
  )
  result <- speed(
    data = custom_obj_data,
    swap = "treatment",
    spatial_factors = ~ row + col,
    obj_function = custom_obj_function(),
    iterations = 1000,
    seed = 42,
    quiet = TRUE
  )
  expect_s3_class(result, "design")

  expect_equal(result$score, 0)
  expect_equal(result$iterations_run, 742)
  expect_equal(result$stopped_early, TRUE)

  vdiffr::expect_doppelganger("speed_custom_obj_func", autoplot(result))
})

test_that("speed handles large grid layouts", {
  large_grid_data <- data.frame(
    row = rep(1:20, each = 20),
    col = rep(1:20, times = 20),
    treatment = rep(LETTERS[1:10], 40)
  )
  result <- speed(
    data = large_grid_data,
    swap = "treatment",
    spatial_factors = ~ row + col,
    iterations = 2000,
    seed = 42,
    quiet = TRUE
  )
  expect_s3_class(result, "design")

  vdiffr::expect_doppelganger("speed_large_grid", autoplot(result))
})

test_that("speed handles large layouts with blocking", {
  large_blocked_data <- data.frame(
    row = rep(1:16, each = 16),
    col = rep(1:16, times = 16),
    block = rep(1:4, each = 64),
    treatment = rep(LETTERS[1:16], 16)
  )
  result <- speed(
    data = large_blocked_data,
    swap = "treatment",
    swap_within = "block",
    spatial_factors = ~ row + col + block,
    iterations = 5000,
    early_stop_iterations = 1000,
    seed = 42,
    quiet = TRUE
  )
  expect_s3_class(result, "design")

  expect_equal(result$iterations_run, 5000)
  expect_equal(result$stopped_early, FALSE)

  expect_snapshot(result$design_df)

  vdiffr::expect_doppelganger("speed_large_blocks", autoplot(result))
})

test_that("speed handles irregular layouts with 400 unique plots", {
  irregular_large_data <- data.frame(
    row = rep(1:20, each = 20),
    col = rep(1:20, times = 20),
    treatment = rep(LETTERS[1:10], 40)
  )

  set.seed(123)
  irregular_large_data$treatment[sample(1:nrow(irregular_large_data), 50)] <- NA

  result <- speed(
    data = irregular_large_data,
    swap = "treatment",
    spatial_factors = ~ row + col,
    iterations = 4000,
    seed = 42,
    quiet = TRUE
  )

  expect_s3_class(result, "design")
  expect_equal(result$iterations_run, 4000)
  expect_equal(result$stopped_early, FALSE)

  expect_identical(
    which(is.na(result$design_df$treatment)),
    which(is.na(irregular_large_data$treatment))
  )

  vdiffr::expect_doppelganger("speed_large_missing", autoplot(result))
})

test_that("speed handles irregular layouts with a clump of missing plots", {
  # Clumped missing plots
  irregular_large_data <- data.frame(
    row = rep(1:20, each = 20),
    col = rep(1:20, times = 20),
    treatment = rep(LETTERS[1:10], 40)
  )

  # Keep only unique row-column combinations
  irregular_large_data[
    irregular_large_data$row %in% 13:16 & irregular_large_data$col %in% 7:10,
    "treatment"
  ] <- NA

  result <- speed(
    data = irregular_large_data,
    swap = "treatment",
    spatial_factors = ~ row + col,
    iterations = 4000,
    seed = 42,
    quiet = TRUE
  )

  expect_s3_class(result, "design")
  expect_equal(result$iterations_run, 4000)
  expect_equal(result$stopped_early, FALSE)

  expect_identical(
    which(is.na(result$design_df$treatment)),
    which(is.na(irregular_large_data$treatment))
  )

  vdiffr::expect_doppelganger("speed_large_missing_clump", autoplot(result))
})

test_that("speed handles irregular layouts with L shaped plots", {
  # Large section of missing plots
  irregular_large_data <- data.frame(
    row = rep(1:20, each = 20),
    col = rep(1:20, times = 20),
    treatment = rep(LETTERS[1:10], 40)
  )

  # Keep only unique row-column combinations
  irregular_large_data[
    irregular_large_data$row %in% 1:14 & irregular_large_data$col %in% 13:20,
    "treatment"
  ] <- NA

  result <- speed(
    data = irregular_large_data,
    swap = "treatment",
    spatial_factors = ~ row + col,
    iterations = 4000,
    seed = 42,
    quiet = TRUE
  )

  expect_s3_class(result, "design")
  expect_equal(result$iterations_run, 4000)
  expect_equal(result$stopped_early, FALSE)

  expect_identical(
    which(is.na(result$design_df$treatment)),
    which(is.na(irregular_large_data$treatment))
  )

  vdiffr::expect_doppelganger("speed_large_missing_L", autoplot(result))
})

# Test cases from Jules_example_cases.R

test_that("speed handles 2D blocking with row and column blocks", {
  dat_2d_blocking <- data.frame(
    row = rep(1:20, each = 20),
    col = rep(1:20, 20),
    treat = rep(paste("V", 1:40, sep = ""), 10),
    rowBlock = rep(1:10, each = 40),
    colBlock = rep(rep(1:10, times = 20), each = 2)
  )
  dat_2d_blocking <- dat_2d_blocking[
    order(dat_2d_blocking$col, dat_2d_blocking$row),
  ]

  result <- speed(
    dat_2d_blocking,
    swap = "treat",
    swap_within = "rowBlock",
    spatial_factors = ~colBlock,
    iterations = 1000,
    early_stop_iterations = 500,
    optimise_params = optim_params(
      swap_count = 5,
      swap_all_blocks = TRUE,
      adaptive_swaps = TRUE,
      cooling_rate = 0.99,
      random_initialisation = TRUE
    ),
    seed = 123,
    quiet = TRUE
  )

  expect_s3_class(result, "design")
  expect_equal(nrow(result$design_df), 400)
  expect_equal(ncol(result$design_df), 5)

  # Check that treatments are balanced within rowBlocks
  rowblock_treatment_counts <- table(
    result$design_df$rowBlock,
    result$design_df$treat
  )
  expect_true(all(rowSums(rowblock_treatment_counts) == 40))

  vdiffr::expect_doppelganger(
    "speed_2d_blocking_rowblock",
    autoplot(result, treatments = "treat", block = "rowBlock")
  )
  vdiffr::expect_doppelganger(
    "speed_2d_blocking_colblock",
    autoplot(result, treatments = "treat", block = "colBlock")
  )
})

test_that("speed handles RCBD with multiple treatment reps", {
  dat_rcbd <- data.frame(
    row = rep(1:25, each = 20),
    col = rep(1:20, 25),
    treat = rep(paste("V", 1:10, sep = ""), 50),
    block = rep(1:50, each = 10)
  )

  result <- speed(
    dat_rcbd,
    swap = "treat",
    swap_within = "block",
    iterations = 2000,
    early_stop_iterations = 1000,
    optimise_params = optim_params(swap_count = 3, adaptive_swaps = TRUE),
    seed = 42,
    quiet = TRUE
  )

  expect_s3_class(result, "design")
  expect_equal(nrow(result$design_df), 500)
  expect_equal(ncol(result$design_df), 4)

  # Check that each block has exactly 10 treatments
  block_sizes <- table(result$design_df$block)
  expect_true(all(block_sizes == 10))

  # Check that treatments are properly distributed within blocks
  block_treatment_counts <- table(
    result$design_df$block,
    result$design_df$treat
  )
  expect_true(all(rowSums(block_treatment_counts) == 10))

  vdiffr::expect_doppelganger(
    "speed_rcbd_multi_reps",
    autoplot(result, treatments = "treat")
  )
})

test_that("speed handles partial replication designs", {
  set.seed(456) # For reproducible random sampling

  treats <- sample(paste("V", 1:150, sep = ""), 150, replace = FALSE)
  trep <- sample(treats, 50, replace = FALSE)
  tunrep <- treats[!(treats %in% trep)]
  treat <- unlist(lapply(
    split(tunrep, rep(1:2, each = 50)),
    function(el, trep) c(el, trep),
    trep
  ))

  dat_partial <- data.frame(
    row = rep(1:20, each = 10),
    col = rep(1:10, 20),
    treat = treat,
    block = rep(1:2, each = 100)
  )

  result <- speed(
    dat_partial,
    swap = "treat",
    swap_within = "block",
    spatial_factors = ~ row + col,
    iterations = 1000,
    early_stop_iterations = 500,
    seed = 42,
    quiet = TRUE
  )

  expect_s3_class(result, "design")
  expect_equal(nrow(result$design_df), 200)
  expect_equal(ncol(result$design_df), 4)

  # Check that each block has 100 plots
  block_sizes <- table(result$design_df$block)
  expect_true(all(block_sizes == 100))

  # Check that replicated treatments appear in both blocks
  block1_treats <- unique(result$design_df$treat[result$design_df$block == 1])
  block2_treats <- unique(result$design_df$treat[result$design_df$block == 2])
  replicated_treats <- intersect(block1_treats, block2_treats)
  expect_equal(length(replicated_treats), 50)

  vdiffr::expect_doppelganger(
    "speed_partial_rep",
    autoplot(result, treatments = "treat")
  )
})

test_that("speed handles large RCBD with 500 treatments", {
  dat_large <- data.frame(
    row = rep(1:50, times = 40),
    col = rep(1:40, each = 50),
    treat = rep(paste("V", 1:500, sep = ""), 4),
    block = rep(1:4, each = 500)
  )

  result <- speed(
    dat_large,
    swap = "treat",
    swap_within = "block",
    spatial_factors = ~ row + col,
    iterations = 1000,
    early_stop_iterations = 400,
    optimise_params = optim_params(swap_count = 10),
    seed = 42,
    quiet = TRUE
  )

  expect_s3_class(result, "design")
  expect_equal(nrow(result$design_df), 2000)
  expect_equal(ncol(result$design_df), 4)

  # Check that each block has exactly 500 treatments
  block_sizes <- table(result$design_df$block)
  expect_true(all(block_sizes == 500))

  # Check that each treatment appears exactly once per block
  block_treatment_counts <- table(
    result$design_df$block,
    result$design_df$treat
  )
  expect_true(all(block_treatment_counts %in% c(0, 1)))
  expect_true(all(colSums(block_treatment_counts) == 4)) # Each treatment in 4 blocks

  # Check row and column balance
  row_treatment_counts <- table(result$design_df$treat, result$design_df$row)
  col_treatment_counts <- table(result$design_df$treat, result$design_df$col)

  # Each treatment should appear in limited number of rows/columns
  row_appearances <- rowSums(row_treatment_counts > 0)
  col_appearances <- rowSums(col_treatment_counts > 0)
  expect_true(all(row_appearances <= 4)) # Max 4 rows per treatment
  expect_true(all(col_appearances <= 4)) # Max 4 columns per treatment

  vdiffr::expect_doppelganger(
    "speed_large_rcbd",
    autoplot(result, treatments = "treat", legend = FALSE)
  )
})

test_that("speed runs with piepho objective", {
  treatments <- rep(1:6)
  df_initial <- initialise_design_df(treatments, 6, 3)
  pair_mapping <- create_pair_mapping(treatments)

  df_initial$row <- factor(df_initial$row)
  df_initial$col <- factor(df_initial$col)
  initial_score <- objective_function_piepho(
    df_initial,
    "treatment",
    c("row", "col")
  )$score

  speed_design <- speed(
    data = df_initial,
    swap = "treatment",
    spatial_factors = ~ row + col,
    optimise_params = optim_params(random_initialisation = TRUE),
    seed = 112,
    quiet = TRUE,
    obj_function = objective_function_piepho,
    pair_mapping = pair_mapping
  )

  expect_lt(speed_design$score, initial_score)
})
