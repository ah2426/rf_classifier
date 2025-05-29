#' examines & cleanses Data_ZT12.csv
#'
#' Name: Ao H
#' Date: 2025-05-28
#' Envs: Seurat5
 
library(tidyverse)
library(here)

DATA = here("data/Data_ZT12.csv")
SAVE_DIR = here("outs/check_data")
dir.create(SAVE_DIR, recursive = TRUE)

df = read_csv(DATA, show_col_types = FALSE) |> print()
X  = df[, setdiff(colnames(df), "true_id")] |> column_to_rownames("sample_id")
y  = df[, "true_id"]

# number of features that are all zeros (or 1e-20)
# more general: features with variance 0
# cols_zero_idx = which(colMeans(X) <= 1e-20)
cols_zero_var_idx = which(apply(X, 2, sd) == 0)
cols_zero = colnames(X)[cols_zero_var_idx]
cat('\n--> genus with 0 variance:', '\n')
print(cols_zero)

# caret::nearZeroVar()
cols_zero_var_idx = caret::nearZeroVar(
    X, saveMetrics = FALSE
)
cols_zero = colnames(X)[cols_zero_var_idx]
cat('\n--> genus with ~0 variance:', '\n')
print(cols_zero)


# rowSums eq. 1 for all subjects?
row_sums = rowSums(X)
cat('\n--> row sums (expected 1):', '\n')
print(row_sums)


# # check endpoint distribution --------------------

# features = c("Dwaynesavagella", "Unclassified.Muribaculaceae", "Scatomonas", "Duncaniella",
#              "Helicobacter_I", "Helicobacter_C",
#              "Unclassified.Muribaculaceae", "Clostridium_AP_143938")
# df_sub = df[c(features, "true_id")] |>
#     pivot_longer(-true_id, names_to = "features", values_to = "frequency")

# p = ggplot(df_sub, aes(x=true_id, y=frequency)) +
#     facet_wrap(~ features, scales="free") +
#     geom_boxplot(outlier.shape = NA) + 
#     geom_point(aes(fill=true_id), shape=21, color="white", size=3, alpha = 0.6,
#                position = position_jitter()) + 
#     theme_minimal() +
#     scale_y_log10() + 
#     labs(x="", y="frequency")
# pdf(file.path(SAVE_DIR, "freq_selected_features.pdf"), width=9, height=5)
# print(p)
# dev.off()

# p = ggpubr::ggdensity(df_sub, x="frequency", add="mean", rug=TRUE,
#                       color="true_id", fill="true_id") +
#     facet_wrap(~ features, scales="free") + 
#     theme_minimal() + 
#     scale_x_log10() +
#     labs(x="frequency", y="density")
# pdf(file.path(SAVE_DIR, "freq_selected_features_density.pdf"), width=9, height=5)
# print(p)
# dev.off()


# Remove all-0s genus & scale columns -------------------

X_clean = X[, setdiff(colnames(X), cols_zero)]
df_X = X_clean |> as.data.frame() |> rownames_to_column("sample_id") |>
    as_tibble()
df_clean = df |> select(c(sample_id, true_id)) |>
    left_join(df_X, by="sample_id")
write_csv(df_clean, here("data/Data_ZT12_clean.csv"))

df_clean = df_clean |> rename(endpoint = true_id) |>
    mutate(endpoint = ifelse(endpoint == "Survived", 1, 0)) |>
    mutate(endpoint = as.numeric(endpoint))
write_csv(df_clean, here("data/Data_ZT12_clean_enet.csv")) 

# #X_scale = scale(X_clean)
# X_scale = log10(X_clean) |> scale()
# df_X = X_scale |> as.data.frame() |> rownames_to_column("sample_id") |>
#     as_tibble()
# print(df_X)

# #print(X_scale)
# #print(colMeans(X_scale))
# #apply(X_scale, 2, sd)

# df_clean = df |> select(c(sample_id, true_id)) |>
#     left_join(df_X, by="sample_id")
# write_csv(df_clean, here("data/Data_ZT12_clean_log_scale.csv"))


# # for elastic net classification --------------------

# df_clean = df_clean |> rename(endpoint = true_id) |>
#     mutate(endpoint = ifelse(endpoint == "Survived", 1, 0)) |>
#     mutate(endpoint = as.numeric(endpoint)) |>
#     print()

# write_csv(df_clean,  here("data/Data_ZT12_clean_log_scale_enet.csv"))
