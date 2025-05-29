#' main script to run random forest (RF) classifier
#'
#' NOTE
#'
#' Name: Ao Huang
#' Date: 2025-05-27

rm(list = ls())
set.seed(72) # random seed for reproducibility
library(tidyverse)
library(here)
library(randomForest) # power RF training 
library(caret) # train test partition 
library(yardstick) # model metric

# CONSOLE INPUT -------------------

PROJ = here()
args = commandArgs(trailingOnly = TRUE)
DATA = args[1] # ** OR replace with data filename, e.g. demo.csv
DATA_FILE = file.path(PROJ, "data", DATA)
PROJ_IDX = sub("\\.[^.]*$", "", basename(DATA_FILE))

# save/output directory
SAVE_DIR = file.path(PROJ,'outs',PROJ_IDX)
dir.create(SAVE_DIR, recursive=TRUE, showWarnings=FALSE)

# helper functions
SCRIPT = file.path(PROJ,'src')
source(file.path(SCRIPT, "source_all.R"))
source_all(SCRIPT)

# CONFIG --------------------
# ** configuration before run

TRAIN_TEST_SPLIT = FALSE
NUM_TREE = 100          # number of trees to include in RF
RF_METRIC = 'Accuracy'  # IMPORTANT PARAMETER
PCT_PARTITION = 0.80    # percentage of train-test partition

# CONSOLE REPORT --------------------
cat('\n',str_pad('# CONSOLE REPORT: ',60,'right','-'),'\n',sep='')
cat('DATA_FILE:', DATA_FILE, '\n')
cat('SAVE_DIR:', SAVE_DIR, '\n')
cat('NUM_TREE:', NUM_TREE, '\n')
cat('RF_METRIC:', RF_METRIC, '\n')
cat('PCT_PARTITION:', PCT_PARTITION, '\n')


# LOAD & PREPROC DATA --------------------------------------------------------
cat('\n\n',str_pad(' LOAD & PREPROC DATA ',80,'both','-'),'\n\n',sep='')

# load data
df = read_csv(DATA_FILE, show_col_types = FALSE) |> 
    print()
df = df |> as.data.frame() |> column_to_rownames("sample_id")

# keep "endpoint" colname consistent
potential_cols = c("endpoint")
idx = which(colnames(df) %in% potential_cols)
colnames(df)[idx] = "endpoint"

df = df |> mutate(endpoint = as.character(endpoint))

# train-test partition --------------------
train_idx = createDataPartition(df$endpoint, p=PCT_PARTITION, list=FALSE)
df_train = df[train_idx, ]
df_test  = df[-train_idx,]

df_train |> rownames_to_column("sample_id") |> write_csv(file.path(SAVE_DIR, "train.csv"))
df_test |> rownames_to_column("sample_id") |> write_csv(file.path(SAVE_DIR, "test.csv"))

# # downsampling (faster training) --------------------
# # ** not applicable
# NUM_SAMPLE = 100
# if (DOWNSAMPLE) {
#     df_train = df_train %>%
#         group_by(endpoint) %>% 
#         slice_sample(n=NUM_SAMPLE, replace=FALSE)
# }

# before-training display --------------------
cat('--> train-test split:', '\n')
table(df_train$endpoint)
table(df_test$endpoint)

cat('--> TRAIN dim:\n')
print(dim(df_train))

cat('--> TEST dim:\n')
print(dim(df_test))


# training RF classifier -----------------------------------------------------
cat('\n\n',str_pad(' training RF classifier ',80,'both','-'),'\n\n',sep='')

toc = Sys.time()
model = rf_classifier(df_train, ntree = NUM_TREE, metric=RF_METRIC)
tic = Sys.time()

cat('\n--> Time Spent:\n')
print(tic-toc)

cat('\n--> Model Summary:\n')
print(model)

cat('\n--> Feature importance:', '\n')
df_imp = varImp(model)$importance |> 
    rownames_to_column("feature") |>
    mutate(importance = rowMeans(across(-feature))) |>
    arrange(desc(importance))
print(varImp(model))
pdf(file=file.path(SAVE_DIR,"rf_feature_importance.pdf"), width=6.5, height=7)
    p = plot_importance(df_imp, n_top=15)
    print(p)
dev.off()

saveRDS(model, file.path(SAVE_DIR, "rf_model.RDS"))
write_csv(df_imp, file.path(SAVE_DIR, "df_importance.csv"))


# test RF classifier ----------------------------------------------------------
cat('\n\n',str_pad(' test RF classifier ',80,'both','-'),'\n\n',sep='')

# ** basically don't do train-test split
#df_test = df_train

TEST.score = make_prediction(model, df_test)
TEST.score$endpoint = factor(TEST.score$endpoint)
TEST.score$predicted.id = factor(TEST.score$predicted.id)

# save TEST.score
write_csv(TEST.score, file.path(SAVE_DIR, "df_test_prediction.csv"))

# test metric statistics
df_metric = pred_evaluate(TEST.score, per_class=FALSE) |>
    as.data.frame()
print(df_metric)

# visual: confusion heatmap
pdf(file=file.path(SAVE_DIR,"rf_confusion.pdf"), width=8, height=8)
    p=plot_confusion(TEST.score)
    print(p)
dev.off()

# visual: auroc curve
# ** skip for now, easier for two-class task


# ANALYSIS FINISHED -----------------------------------------------------------
cat('\n\n',str_pad(' ANALYSIS FINISHED ',80,'both','-'),'\n\n',sep='')
