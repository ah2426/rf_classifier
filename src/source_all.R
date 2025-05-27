source_all = function (path) {
    files = list.files(path, pattern="*.R", full.names = TRUE)
    cat('--> functions loaded:', '\n')

    for (file in files) {
        source(file)
        cat(basename(file), "\n")
    }

    cat("\n")
}