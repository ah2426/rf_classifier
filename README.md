# random forest (rf) for classification task

[!NOTE]
1. data table should be put under `./data`, e.g. `./data/demo.csv`
2. data table should have samples as row, features as column
3. data table should contain columns named `true.id` (class labels to be predicted) 
   and `sample_id` (a unique id for each row/sample)

### dependencies

check `environment.yml`

### run

1. navigate the directory to this folder `/your_path/rf_classifier`
2. run the main script with data filename (e.g. `demo.csv`) as an input
```
Rscript main_rf.R demo.csv
```
3. the trained model, intermediate files, and some output plots are saved under 
   `./outs/[your_data_filename]`
