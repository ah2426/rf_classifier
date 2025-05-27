# random forest (rf) for classification task

> [!NOTE]
> data table should be put under `./data`, e.g. `./data/demo.csv`, and have
> samples as row and features as column. The data table should contain columns 
> named `true.id` (class labels to be predicted) and `sample_id` (a unique id for each row/sample)

### Dependencies

check `environment.yml`

### Run

1. navigate the directory to this folder `/your_path/rf_classifier`
2. run the main script with data filename (e.g. `demo.csv`) as input
```
Rscript main_rf.R demo.csv
```
3. the trained model, intermediate files, and some output plots are stored under `./outs/[data_filename]`

### elastic-net models

1. this is for when the endpoint is continuous -- because of significance is determined through permutation,
   this pipeline takes **longer** to run
2. run the main script with data filename (e.g. `demo_mpg.csv`) as input
```
Rscript main_enet.R demo_mpg.csv
```

