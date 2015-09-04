#' Combine data from xcms results for the plotting purpose
#' 
#' Take results from xcms \link[xcms]{diffreport} for both positive and negative
#' modes, extract all given m/z and corresponding statistical values.
#' 
#' @param pos a data.frame from xcms \link[xcms]{diffreport}. Positive m/z 
#'   values
#' @param neg a data.frame from xcms \link[xcms]{diffreport}. Negative m/z 
#'   values
#' @return A list with extracted m/z, folds, tstat and pvalues.
#' \item{mz}{a vector of all m/z. First positive, then negative.}
#' \item{folds}{a vector, showing how the mean value of \code{class2} differs
#'   from the mean value in \code{class1}. When the mean of \code{class1} equals
#'   to 0 or NA \code{fold} value become \code{Inf}. But that means that no such
#'   peak is present in negative control, so fold value is changed to maximum 
#'   possible in this dataset}
#' \item{tstat}{a vector with Welch's t test statistic of fold values. Can be 
#' negative if \code{class1} is greater then \code{class2}} 
#' \item{pvalue}{a vector of p-value of t-statistic}
#'   
#' @details Returned list is a combination of \code{pos} and \code{neg} (in this
#'   order) values.
#'   
#'   Sometimes \code{folds} can be \code{Inf}, so they are converted to 
#'   \code{max} value. 
#'\preformatted{xcmsSet.R:diffreport()
#'... 
#'## c1 and c2 are columns of class1 and class2 resp.
#'c1 <- which(classlabel %in% class1) 
#'c2 <- which(classlabel %in% class2)
#'   
#'## calculate both class means 
#'mean1 <- rowMeans(values[,c1], na.rm = TRUE) 
#'mean2 <- rowMeans(values[,c2], na.rm = TRUE)
#'  
#'## Calculate fold change. 
#'## For foldchange <1 set fold to 1/fold 
#'fold <- mean2 / mean1 
#'fold[!is.na(fold) & fold < 1] <- 1/fold[!is.na(fold) & fold < 1] 
#'}
#'@seealso \link[xcms]{diffreport}
combine_ms_data_rt <- function (pos, neg) {
    mz <- c(pos$mzmed, neg$mzmed)    
    folds <- c (pos$fold, -neg$fold) 
    if (length (folds) == 0) {return (FALSE)}
    # Folds can be INF, so we need to handle them
    tempF <- folds
    # Replace Inf with NA
    tempF[is.infinite(folds)] <- NA
    tempMax <- max (tempF, na.rm = TRUE)
    # Replace now NA with maximum values
    folds[is.infinite(folds)] <- tempMax
    
    tstat <- c (pos$tstat, neg$tstat)
    pvalue <- c(pos$pvalue, neg$pvalue)
    
    return (list (mz=mz, folds=folds, tstat=tstat, pvalue=pvalue))   
}

#' Default scripting for getting xcms data
#' 
#' Function contains allmost all needable commands to get results from xcms 
#' package. Still the main command (\link[xcms]{diffreport}) is required as an 
#' argument
#' 
#' @param directory a location of grouped chromatograms in accesable format
#' @param retMethod What method should be used in \link[xcms]{retcor} function. 
#'   Default method is "loess." Another possible variant is "obiwarp"
#' @param ... parameters passed to \link[xcms]{diffreport} method
#'   
#' @details xcms \link[xcms]{diffreport} method returns the data.frame in which 
#'   retention time is showed in seconds. \code{\link{get_xcms_result}}
#'   transforms them into minute values
get_xcms_result <- function (directory, retMethod="loess", ...) {
    files_lc <- list.files (directory, recursive = TRUE, full.names = TRUE)
    # Create xcms classes based on the files
    xset <- xcmsSet (files_lc)
    # Group sets together basing on the directories separation
    xset <- group (xset)
    # Correct retention times. One of the important steps
    xset_ret <- retcor (xset, method=retMethod) # Another method is obiwarp
    # Group them againt after correction
    xset_ret <- group (xset_ret, bw = 30)
    # Fill missing values
    xset_filled <- fillPeaks (xset_ret)
    
    # Calculate statistical differences between groups 
    #######################
    # SET THIS FOR EACH EXPERIMENT BY HAND!!!!
    report <- diffreport (xset_filled, ...)
    
    ########################
    # Now we need a filter all data.
    # First, it is easy to deal with minutes then with seconds
    rtime <- report
    rtime$rtmed <- rtime$rtmed / 60
    
    return (rtime)
}
