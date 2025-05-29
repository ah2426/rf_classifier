#' main script to run elastic-net regression
#'
#' NOTE
#' when endpoint is continuous, select "gaussian"
#' when endpoint is discrete (two-class), select "binomial"
#'
#' Name: Ao Huang
#' Date: 2025-05-27

rm(list = ls())
set.seed(72) # random seed for reproducibility
library(tidyverse)
library(here)

# install eNetXplorer if haven't
if (!require(devtools)) {
    install.packages("devtools")
}

if (!require(eNetXplorer)) {
    devtools::install_github("juliancandia/eNetXplorer")
}

# CONSOLE INPUT -------------------

PROJ = here()
args = commandArgs(trailingOnly = TRUE)
DATA = args[1] # ** OR replace with data filename, e.g. demo_mpg.csv
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
FAMILY = "binomial" # ** or gaussian
ALPHAS = seq(0,1,by=0.1) # c(0.1,0.5,0.9) 0:ridge, 1:lasso
N_RUN  = 50 # number of cross-validation runs
N_PERM = 25 # number of permutation to generate null distribution

# CONSOLE REPORT --------------------
cat('\n',str_pad('# CONSOLE REPORT: ',60,'right','-'),'\n',sep='')
cat('DATA_FILE:', DATA_FILE, '\n')
cat('SAVE_DIR:', SAVE_DIR, '\n')
cat('FAMILY:', FAMILY, '\n')
cat('ALPHAS:', ALPHAS, '\n')

# ** set working dir to the save_dir
setwd(SAVE_DIR)


# LOAD & PREPROC DATA --------------------------------------------------------
cat('\n\n',str_pad(' LOAD & PREPROC DATA ',80,'both','-'),'\n\n',sep='')

# load data
df = read_csv(DATA_FILE, show_col_types = FALSE) |> 
    print()
df = df |> as.data.frame() |> column_to_rownames("sample_id") |>
    as.matrix()

y = df[, "endpoint"] # endpoint for prediction
X = df[, setdiff(colnames(df), "endpoint")]

cat('--> data dim:', '\n')
print(dim(df))


# TRAIN ELASTIC NET -----------------------------------------------------------
cat('\n\n',str_pad(' TRAIN ELASTIC NET ',80,'both','-'),'\n\n',sep='')

# # ** parallel run
# library(future)
# eNet = ALPHAS %>% furrr::future_map(
#     ~ eNetXplorer(
#         x=X, y=y,
#         family="gaussian",
#         scaled = TRUE, # ** scale each feature
#         n_run=100, n_perm_null=100, n_fold=10,
#         save_obj=T, dest_obj=paste0("eNet_a",.x,".Robj"),
#         alpha=.x
#     ),
#     .options = furrr_options(seed = TRUE)
# )

toc = Sys.time()

# normal run
eNet = eNetXplorer(
    x = X, y = y,
    family = FAMILY, # gaussian or binomial
    alpha = ALPHAS,
    n_run = N_RUN, n_perm_null = N_PERM, n_fold = 10,
    seed = 72,
    save_obj = TRUE,
    dest_dir = SAVE_DIR, dest_obj = "enet_model.Robj"
)

tic = Sys.time()

cat('\n--> Time Spent:\n')
print(tic-toc)

cat('\n--> Model Summary:\n')
print(summary(eNet))

# save family of enet models
# mergeObj( paste0("eNet_a", ALPHAS, ".Robj") )
# saveRDS(eNet, file.path(SAVE_DIR, "eNet_merged.Robj"))
cat('\n--> eNet model SAVED \n')


# TRAIN STATISTICS ------------------------------------------------------------
cat('\n\n',str_pad(' TRAIN STATISTICS ',80,'both','-'),'\n\n',sep='')

load(file.path(SAVE_DIR, "enet_model.Robj"))
visual_enet_fit(eNet, save_file = file.path(SAVE_DIR, "enet_fit.pdf"))


# ANALYSIS FINISHED -----------------------------------------------------------
cat('\n\n',str_pad(' ANALYSIS FINISHED ',80,'both','-'),'\n\n',sep='')
