# This script defines the random forest classifer with configurations in train-
# test split, cross validation and training
# Name: Ao Huang
# Date: Jan 17 2024

rf_classifier = function (expr_df, ntree, metric) {
    # Returns the RF model that's trained with input data
    # 
    # Parameter expr_df: a cell-by-(feature+cell_type) data frame
    # Preconditions: cell-by-feature entries are floats, cell_type entries are 
    # factors
    # 
    # Parameter ntree: number of trees used in RF model
    # Preconditions: an integer

    ## load libraries
    library(randomForest)
    library(caret)

    ## control training 
    train_ctrl = trainControl(method = 'cv',
                              number = 10,
                              #summaryFunction = f1,
                              search = 'grid')

    ## train RF classifier
    model = train(true.id ~ .,
                  data = expr_df,
                  method = 'rf', # use randomForest::randomForest
                  metric = metric, # 'Accuracy' or 'F1'
                  trControl = train_ctrl,
                  # options to pass to RF
                  ntree = ntree,
                  keep.forest = TRUE,
                  importance = TRUE)

    return(model)
}


# source: https://stackoverflow.com/questions/69706479/use-f1-score-as-metric-for-multiclass-prediction

f1 <- function(data, lev = NULL, model = NULL) {
    f1_val <- f1_score(data$pred,data$obs)
    names(f1_val) <- c("F1")
    f1_val
}

f1_score <- function(predicted, expected, positive.class="1") {
    predicted <- factor(as.character(predicted), levels=unique(as.character(expected)))
    expected  <- as.factor(expected)
    cm = as.matrix(table(expected, predicted))

    precision <- diag(cm) / colSums(cm)
    recall <- diag(cm) / rowSums(cm)
    f1 <-  ifelse(precision + recall == 0, 0, 2 * precision * recall / (precision + recall))

    #Assuming that F1 is zero when it's not possible compute it
    f1[is.na(f1)] <- 0

    #Binary F1 or Multi-class macro-averaged F1
    ifelse(nlevels(expected) == 2, f1[positive.class], mean(f1))
}
