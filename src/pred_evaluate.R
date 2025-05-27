
pred_evaluate = function (TEST.score, per_class=FALSE) {

    library(yardstick)
    
    if (!per_class) {

        output = calc_metric(TEST.score)

    } else {
        
        uniq_class = unique(TEST.score$true.id)
        metric = c('accuracy', 'precision', 'recall', 'f1_score')
        output = data.frame(matrix(0, ncol=length(metric), nrow=length(uniq_class)))
        names(output) = metric

        truth = TEST.score$true.id
        estimate = TEST.score$predicted.id

        for (i in 1:length(uniq_class)) {
            output[i,] = cal_metric_per_class(
                truth=truth, 
                estimate=estimate, 
                class_label=uniq_class[i]
            )
        }

        output = output %>% mutate(true.id=uniq_class)

    }

    return(output)
}


calc_metric = function (TEST.score) {
    # Returns common metrics in accessing classifier performance
    # 
    # Metrics include:
    # accuracy  := TP+TN / ALL
    # precision := TP / TP+FP (macro.average for multi-class)
    # recall    := TP / TP+FN (macro.average for multi-class)
    # f1_score  := harmonic_mean(precision, recall)
    # auroc
    # auprc

    rm_colnames = c("sample_id", "true.id", "predicted.id")
    var_names = setdiff(colnames(TEST.score), rm_colnames)
    #print(var_names)

    # compute prediction metrics
    accuracy = yardstick::metrics(TEST.score, true.id, predicted.id)$.estimate[1]
    precision= yardstick::precision(TEST.score, true.id, predicted.id)$.estimate[1]
    recall   = yardstick::recall(TEST.score, true.id, predicted.id)$.estimate[1]
    f1    = yardstick::f_meas(TEST.score, true.id, predicted.id)$.estimate[1]
    auroc = yardstick::roc_auc(TEST.score, true.id, var_names)$.estimate
    auprc = yardstick::pr_auc(TEST.score, true.id,  var_names)$.estimate
        
    output = c(accuracy=accuracy, precision=precision, recall=recall,
                f1_score=f1, auroc=auroc,auprc=auprc)

    return(output)
}


cal_metric_per_class = function (truth, estimate, class_label) {

    binary_df = make_binary(truth, estimate, class_label)

    accuracy = yardstick::metrics(binary_df, truth, estimate)$.estimate[1]
    precision = yardstick::precision(binary_df, truth, estimate)$.estimate[1]
    recall = yardstick::recall(binary_df, truth, estimate)$.estimate[1]
    f1  = yardstick::f_meas(binary_df, truth, estimate)$.estimate[1]

    output = c(accuracy=accuracy, precision=precision, recall=recall, f1_score=f1)
    return(output)

}


make_binary = function (truth, estimate, class_label) {

    truth_binary = rep(0, length(truth))
    estim_binary = rep(0, length(estimate))

    # turn to class 1 if matching the class_label
    truth_binary[truth == class_label] = 1
    estim_binary[estimate == class_label] = 1

    # make factor as input to yardstick
    # setting the level is important, otherwise yardstick make '0' as positive case
    truth_binary = factor(truth_binary, levels=c('1','0')) 
    estim_binary = factor(estim_binary, levels=c('1','0'))

    binary_df = data.frame(truth=truth_binary, estimate=estim_binary)
    return(binary_df)

}
