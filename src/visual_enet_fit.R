visual_enet_fit = function (eNet, save_file) {
    # visualize
    pdf(save_file, width=12, height=4.5)

        # PLT1: model train summary --------------------
        par(mfrow = c(1,3))
        
        # model performance - different alphas
        plot.eNetXplorer(eNet, plot.type="summary")
        
        # model performance - different lambdas
        plot.eNetXplorer(eNet, 
                        alpha.index=which.max(eNet$model_QF_est),
                        plot.type="lambdaVsQF")
        
        # OOB pred accuracy - best model
        plot.eNetXplorer(eNet,
                        alpha.index = which.max(eNet$model_QF_est), 
                        plot.type = "measuredVsOOB")
        
        # PLT2: top important features --------------------
        # "coef": can display negative/positive effects
        # "freq": freq of non-zero coefs - better p values??
        
        # # default plotting scheme
        # par(mfrow = c(1,1))
        # plot.eNetXplorer(eNet,
        #                  alpha.index = which.max(eNet$model_QF_est),
        #                  plot.type = "featureCaterpillar",
        #                  stat = "coef")
        # plot.eNetXplorer(eNet,
        #                  alpha.index = which.max(eNet$model_QF_est),
        #                  plot.type = "featureCaterpillar",
        #                  stat = "freq")
        
        # self plot scheme
        p1 = plt_caterpillar(eNet,
                            alpha.index = which.max(eNet$model_QF_est),
                            n_top_features = 10,
                            title="Permutation significance",
                            stat = "coef")

        p2 = plt_caterpillar(eNet,
                            alpha.index = which.max(eNet$model_QF_est),
                            n_top_features = 10,
                            title="Permutation significance",
                            stat = "freq")
        print(p1)
        print(p2)
        #do.call("grid.arrange", c(list(p1,p2), ncol=2))
        
        
        # PLT3: important features heatmap -------------------
        #par(mfrow = c(1,2))
        plot.eNetXplorer(eNet,
                        alpha.index = which.max(eNet$model_QF_est), 
                        plot.type = "featureHeatmap", 
                        stat = "coef")
        plot.eNetXplorer(eNet,
                        alpha.index = which.max(eNet$model_QF_est), 
                        plot.type = "featureHeatmap", 
                        stat = "freq")
        
    dev.off()
}


plt_caterpillar = function (x, alpha.index, n_top_features=10, title, stat="freq") {
    
    # preps plot dataframe
    plt_df = .prep_caterpillar(
        x = x,
        alpha.index = alpha.index,
        n_top_features = n_top_features,
        stat = stat
    )
    
    limit_value = max(
        abs(plt_df$feature_mean+plt_df$feature_sd),
        abs(plt_df$feature_mean-plt_df$feature_sd),
        abs(plt_df$null_feature_mean+plt_df$null_feature_sd),
        abs(plt_df$null_feature_mean-plt_df$null_feature_sd)
    ) + 0.002

    # stat-specific
    if (stat == "coef") {
        p = ggplot(plt_df, aes(y = reorder(feature, desc(pval)))) + 
            geom_point(aes(x = feature_mean, color = "Model"), size = 2) +
            geom_errorbar(aes(xmin = feature_mean - feature_sd, 
                            xmax = feature_mean + feature_sd, 
                            color = "Model"), 
                          width = 0.2,linetype="dashed") +
            geom_point(aes(x = null_feature_mean, color = "Null"), size = 2) +
            geom_errorbar(aes(xmin = null_feature_mean - null_feature_sd, 
                            xmax = null_feature_mean + null_feature_sd, 
                            color = "Null"), 
                        width = 0.2, linetype="dashed") +
            labs(y = "", x = "feature coefficient", color = "Type") +
            xlim(-limit_value, limit_value) # ** coef-specific
    } else if (stat == "freq") {
        p = ggplot(plt_df, aes(y = reorder(feature, desc(pval)))) + 
            geom_point(aes(x = feature_mean, color = "Model"), size = 2) +
            geom_errorbar(aes(xmin = lower_bound, 
                              xmax = feature_mean + feature_sd, 
                              color = "Model"), 
                          width = 0.2,linetype="dashed") + 
            geom_point(aes(x = null_feature_mean, color = "Null"), size = 2) +
            geom_errorbar(aes(xmin = lower_bound_null,  # ** freq-specific in plt_df
                              xmax = null_feature_mean + null_feature_sd, 
                              color = "Null"), 
                        width = 0.2, linetype="dashed") +
            labs(y = "", x = "feature frequency", color = "Type")
    }
    
    # common again
    p = p +
        scale_color_manual(values = c(Model="red", Null="darkgrey")) +
        scale_y_discrete(position="right") + 
        ggtitle(title) + 
        theme_bw(base_size=12) #+ 
        # theme(legend.position = c(.95, .05),
        #       legend.background = element_rect(linetype="solid",linewidth=1),
        #       legend.justification = c("right", "bottom"))

    return(p)
}


.prep_caterpillar = function(x, alpha.index, n_top_features, stat) {

    # ** use wmean&wsd or mean&sd
    if (stat == "coef") {
        x$feature_mean = x$feature_coef_wmean
        x$feature_sd   = x$feature_coef_wsd
        x$feature_mean_null = x$null_feature_coef_wmean
        x$feature_sd_null   = x$null_feature_coef_wsd
        x$plt_pval = x$feature_coef_model_vs_null_pval
    } else if (stat == "freq") {
        x$feature_mean = x$feature_freq_mean
        x$feature_sd   = x$feature_freq_sd
        x$feature_mean_null = x$null_feature_freq_mean
        x$feature_sd_null   = x$null_feature_freq_sd
        x$plt_pval = x$feature_freq_model_vs_null_pval
    }

    plt_df = data.frame(
        feature_mean = x$feature_mean[, alpha.index],
        feature_sd   = x$feature_sd[, alpha.index],
        null_feature_mean = x$feature_mean_null[, alpha.index],
        null_feature_sd   = x$feature_sd_null[, alpha.index],
        pval = x$plt_pval[, alpha.index]
    ) |> rownames_to_column("feature") |> 
        filter(!if_any(everything(), is.nan)) |> # remove NaN rows
        arrange(pval) # small to big
    
    if (nrow(plt_df) > n_top_features) {
        plt_df = plt_df[1:n_top_features,]    
    }
    
    # add sig level to feature names
    plt_df$pval_star = ""
    plt_df$pval_star[plt_df$pval < .1]   = "."
    plt_df$pval_star[plt_df$pval < .05]  = "*"
    plt_df$pval_star[plt_df$pval < .01]  = "**"
    plt_df$pval_star[plt_df$pval < .001] = "***"
    plt_df$feature = paste(plt_df$feature, plt_df$pval_star)

    # freq-specific lower bound
    if (stat == "freq") {
        plt_df = plt_df |> 
            mutate(
                lower_bound_null = ifelse(null_feature_mean-null_feature_sd < 0,
                                          0, null_feature_mean-null_feature_sd),
                lower_bound = ifelse(feature_mean-feature_sd < 0,
                                     0, feature_mean - feature_sd)
            )
    }

    return(plt_df)
}
