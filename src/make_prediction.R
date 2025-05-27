make_prediction = function (model, df_test) {
    # Returns a data.frame containing prediction information from the 
    # trained model
    # 
    # data.frame to be returned contains colnames as follows:
    # 'sample_idx': index for sample
    # 'true.id': True labels as in annotations
    # 'predicted.id': labels from model prediction
    # 'class' ...: each class label has a column containing the probability
    # of that sample being predicted to be under that class label
    # 
    # Parameter model: a classifier model object
    # Precondition: a model object
    # 
    # Parameter df_test: a dataframe of test data
    # Precondition: has the same format as the output of data_preprocess()

    predicted.id = predict(model, df_test, 'raw')
    probs = predict(model, df_test, 'prob') |> 
        rownames_to_column("sample_id")

    TEST.score = df_test |> select(c(true.id)) |>
        mutate(predicted.id=predicted.id) |>
        rownames_to_column("sample_id") |>
        left_join(probs, by="sample_id")

    return(TEST.score)
}
