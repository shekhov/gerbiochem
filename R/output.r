#' Print all given data into excel table
#' 
#' For all given data.frames create a sheet in the excel table and save them 
#' there
#' 
#' @param data a list with data.frames to save. Each element in the list is one 
#'   data.frame. Name of the element will be a sheet name.
#' @param filename a name of the file without extention (neither .xls or .xlsx)
#' @param path an optional string. Path to the folder, where file should be 
#'   created. If not specified, file created in working directory.
#'   
#' @details If \code{path} directs to unexistent folder, a new folder will be
#'   created under this path
results_to_excel <- function (data, filename="", path="/") {
    filename <- check_path (path, filename, "result_to_excel")
    res_book <- loadWorkbook (filename = paste (filename,".xlsx"), create = TRUE)
    dataNames <- names (data)
    n <- length (data)
    for (i in 1:n) {
        createSheet (res_book, dataNames[i])
        writeWorksheet (res_book, sheet=dataNames[i], startRow=1, header=TRUE, data=data[[i]])
    }
    saveWorkbook (res_book)
}