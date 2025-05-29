# random forest (rf) for classification task

> [!NOTE]
> for either regression or classification tasks using random forests or 
> elastic-net, the `y` to be predicted is now named `endpoint`

### Dependencies

check `environment.yml`

### Data table format

data table should
1. have samples as row, and features as column
2. contain a column named `endpoint` (either class labels or continuous variable)
3. contain a column named `sample_id` - unique id for each sample/row

### Run

1. navigate to the current directory of this folder `/your/path/rf_classifier`
2. run the main script with data table filename (e.g. `demo_iris.csv`) as input
```
Rscript main_rf.R demo_iris.csv
```
3. the trained model, intermediate files, and some output plots are stored under
   `outs/[filename]`

#### `main_rf.R` for classfication

1. configure: `NUM_TREE` (number of trees), `RF_METRIC` (metric to select the 
   best model), `PCT_PARTITION` (percentage to split train, test data)
2. run `Rscript main_rf.R [filename].csv`

#### `main_enet.R` for classification

1. configure: `FAMILY="binomial"`
2. **important** for `endpoint` to have numerical entries, e.g. `1:"Survived"`,
   `0:"Died"`
3. run `Rscript main_enet.R [filename].csv`

#### `main_enet.R` for regression

1. configure: `FAMILY="gaussian"`
2. `endpoint` is continuous, e.g. in `demo_mpg.csv`
3. run `Rscript main_enet.R [filename].csv`

