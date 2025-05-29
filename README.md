# random forest (rf) for classification task

> [!NOTE]
> data table should be put under `./data`, e.g. `./data/demo_iris.csv`, and have
> samples as row and features as column. The data table should contain columns 
> named `true.id` (class labels to be predicted) and `sample_id` (a unique id for each row/sample)

### Dependencies

check `environment.yml`

### Run

1. navigate the directory to this folder `/your_path/rf_classifier`
2. run the main script with data filename (e.g. `demo_iris.csv`) as input
```
Rscript main_rf.R demo_iris.csv
```
3. the trained model, intermediate files, and some output plots are stored under `./outs/[data_filename]`

### elastic-net models (continuous OR discrete)

1. for elastic-net prediction of continuous endpoint, set `FAMILY="gaussian"` in
   `main_enet.R`; for prediction of binary discrete endpoint, set
   `FAMILY=binomial` instead
2. data table should have a column named `endpoint` that is the continuous/discrete
   endpoint to be predicted
3. run the main script with data filename (e.g. `demo_mpg.csv`) as input
```
Rscript main_enet.R demo_mpg.csv
```

