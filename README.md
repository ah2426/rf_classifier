# random forest (rf) for classification task

> [!NOTE]
> data table should be put under `./data`, e.g. `./data/demo.csv`, and have
> samples as row and features as column. The data table should contain columns 
> named `true.id` (class labels to be predicted) and `sample_id` (a unique id for each row/sample)

### Dependencies

check `environment.yml`

### Run

1. navigate the directory to this folder `/your_path/rf_classifier`
2. run the main script with data filename (e.g. `demo.csv`) as an input
```
Rscript main_rf.R demo.csv
```
3. the trained model, intermediate files, and some output plots are stored under 
   `./outs/[data_filename]`
