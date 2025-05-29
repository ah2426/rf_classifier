plot_confusion = function (TEST.score) {
    # Returns the plot object of the confusion matrix
    # 
    # The x-axis is the true label, the y-axis is the prediced label
    # 
    # Parameter TEST.score: a dataframe of prediction information
    # Preconditon: has the same format as the output of make_prediction()

    library(pheatmap)
    library(RColorBrewer)
    library(viridis)

    confusion = conf_mat(TEST.score, truth=endpoint, estimate=predicted.id)

    labels = colnames(confusion$table)
    mat = matrix(confusion$table, nrow = length(labels))
    mat = t(apply(mat, 1, function (x) {x / sum(x)}))
    rownames(mat)=labels
    colnames(mat)=labels

    p=pheatmap(mat, cluster_cols=F, cluster_rows=F, fontsize = 16, 
               display_numbers = round(mat,2), fontsize_number=16,
               number_color = ifelse(mat >= .6, 'white', 'black'),
               border_color = "black",
               cellwidth = 64, cellheight = 64,
               main = "Confusion matrix",
               color=brewer.pal(n=9, name = "Greens"))
    return(p)
}


# plot_auroc = function (data) {

#     p=ggplot(data, aes(x=1-specificity, y=sensitivity, group=.level)) + 
#     geom_step(aes(color=.level))+
#     geom_abline(slope=1, intercept=0, linetype='dashed')+
#     theme_bw(base_size = 18) + theme(axis.text.x = element_text(angle = 0, hjust = 1))

#     return(p)

# }

plot_importance = function (df_imp, n_top=10) {

    n_top = ifelse(n_top > nrow(df_imp), nrow(df_imp), n_top)
    df_imp = df_imp |> arrange(desc(importance))
    df_imp = df_imp[1:n_top, ]

    p = ggplot(df_imp, aes(x = reorder(feature, importance), 
                           y = importance)) +
        geom_segment(aes(xend=feature, y=0, yend = importance), color = "darkgrey", size = 1) +
        geom_point(color = "black", size = 3) +
        #geom_col(fill = "#377EB8") +
        coord_flip() +
        theme_minimal(base_size=16) +
        labs(x = "", title = "", y = "Importance (Mean Decrease Gini)")

    return(p)
}


