#' Function check excistence of folder and file
check_path <- function (path, filename, defaultName) {
    if (dir.exists(path) == FALSE) dir.create (path)
    if (nchar(filename) == 0) {
        warning ("filename was not specified. File was created with a default name")
        filename <- defaultName
    } 
    return (filename)
}