#' Display Total Ion Chromatogram
#' 
#' Display two/three groups in one plot, where y-axis is a time, and x-axis is a
#' m/z (positive and negative).
#' 
#' @param pos a list of data from xcms-package, containing only positive m/z 
#'   values
#' @param neg a list of data from xcms-package, containing only negative m/z 
#'   values
#' @param datanames a list with three string values, related to the names of 
#'   treatment in the datasets. See \emph{details} for the list structure
#' @param rtRange an optional numerical vector with a time window of data to 
#'   display. If \code{FALSE} (the default) the range function will be used to 
#'   determine window to include all values
#' @param title (optional) an overall title of the plot
#' @param toPDF logical (optional, default is \code{FALSE}). Should the plot be
#'   rendered in pdf device.
#' @param filename path string. Should specify if \code{toPDF} parameter is 
#'   \code{TRUE}. Should have an extension .pdf. Does not create a folder
#' @details \code{\strong{datanames}} Package xcms generate a dataset with 
#'   number of peaks in each time point. The number and names of the columns in 
#'   the dataset depends on your initial file structure. To get access to these 
#'   columns \code{\link{plot_TEIC}} need the names of the folder. Usually there
#'   are two or three groups. This function use three values - \emph{treatment, 
#'   neg_control, pos_control} in this order. So the structure of datanames 
#'   should be \code{datanames$treatment, datanames$neg_control, 
#'   datanames$pos_control} If there are only two groups, function will use only
#'   \emph{treatment} and \emph{neg_control} parameters
#'   
#'   \code{\strong{filename}} If using \code{\link{plot_TEIC}} directly, check 
#'   directory first with \code{\link[base]{dir.exists}} and create one after 
#'   with \code{\link[base]{dir.create}}
plot_TEIC <- function (pos, neg, datanames, rtRange=FALSE, title="", toPDF=FALSE, filename="") {
    if (toPDF & nchar (filename) > 0) {pdf (filename, width=16, height=9)}
    #########################
    # Check datanames integrity
    truenames <- c("treatment", "neg_control", "pos_control")
    realnames <- names (datanames)
    if (sum(truenames[1:length(realnames)] != realnames) > 0) {
        stop ("Wrong datanames! Use treatment, neg_control, pos_control as list names")
    }
    #########################
    # First let's plot just dots
    x <- c (pos$mzmed, -neg$mzmed)
    y <- c (pos$rtmed, neg$rtmed)
    
    ########################
    # The window options
    if (rtRange[1] == FALSE) { rtRange<-c(0, max(y)) } else  { rtRange <- round (rtRange, 0) }
    
    values_to_range <- function (x, y, rtRange) {
        inRange <- (y >= rtRange[1] & y <= rtRange[2])
        res <- list (x=x[inRange == TRUE], y=y[inRange == TRUE])
        return (res)
    }
    
    vR <- values_to_range (x, y, rtRange)
    # Create a window 
    plot (vR$x, vR$y, type = 'n', axes = FALSE, xlab='', ylab='', ylim=rtRange, main=title)
    
    # Horizontal arrows     
    arrows(x0=0, y0=rtRange[1], x1=max(vR$x), y1=rtRange[1], length=0.15)
    arrows(x0=0, y0=rtRange[1], x1=min(vR$x), y1=rtRange[1], length=0.15)
    # Vertical arrow
    arrows(x0=0, y0=rtRange[1], x1=0, y1=rtRange[2], length=0.15)    
    
    # y-ticks position and size
    # Look to the yRange and choose by which value ticks should differ
    yticks_by <- (rtRange[2] - rtRange[1]) / 10
    if (yticks_by >= 5) {yticks_by <- 10}
    else if (yticks_by <= 1) {yticks_by <- 1}
    else if (yticks_by <= 2) {yticks_by <- 2}
    else if (yticks_by < 5) {yticks_by <- 5}
    # Position of y-ticks
    yticks_pos_y <- seq (from=round (rtRange[1], 0), to=round (rtRange[2], 0), by=yticks_by)
    yticks_pos_y <- yticks_pos_y[2:(length (yticks_pos_y)-1)]
    yticks_pos_x <- rep (0, length (yticks_pos_y))
    # Length of a tick
    yticks_l <- sum (abs(range(x))) * 0.005
    # Place ticks on y-axis
    segments (x0=yticks_pos_x-yticks_l, y0 = yticks_pos_y, x1=yticks_pos_x+yticks_l)
    text (x = yticks_pos_x[1] - (5* yticks_l), y = yticks_pos_y, labels = yticks_pos_y, cex = 0.7)
    
    # x-tics position and size
    mzRange <- range (vR$x)
    xticks_pos_x <- round (seq (from=mzRange[1], to=mzRange[2], by=100), -2)
    xticks_pos_y <- rep (rtRange[1], length (xticks_pos_x))
    xticks_l <- (rtRange[2] - rtRange[1]) * 0.005
    segments (x0=xticks_pos_x, y0=xticks_pos_y- xticks_l, y1=xticks_pos_y + xticks_l)
    xticks_first_pos <- xticks_pos_x[xticks_pos_x > 0][1]
    xticks_first_neg <- tail (xticks_pos_x [xticks_pos_x < 0], 1)
    text (x=xticks_pos_x[2:(length(xticks_pos_x)-1)], y=xticks_pos_y[1]-(5*xticks_l),
          labels=xticks_pos_x[2:(length(xticks_pos_x)-1)], cex=0.7)
    
    # Texts for axis
    mtext (text = "rt, min", side = 3,  line = -0.5)
    text (x=xticks_pos_x[1], y=xticks_pos_y[1]-(5*xticks_l), labels="-m/z", cex=0.7)
    text (x=tail(xticks_pos_x, 1), y=xticks_pos_y[1]-(5*xticks_l), labels="+m/z", cex=0.7)
    
    ############################
    # Size of the points to plot
    size_values <- c (pos$tstat * pos$fold, neg$tstat * neg$fold)
    size_max <- max (abs(size_values))
    default_cex <- 1
    point_cex <- default_cex + default_cex*(size_values / size_max)
    # Settings for the points
    neg_point <- list(16, 'green')
    pos_point <- list (2, 'blue')
    tr_point <- list (0, 'red')
    
    # Negative control points
    neg_rule <- c (pos[datanames$neg_control][[1]] > 0, neg[datanames$neg_control][[1]] > 0)
    neg_x <- x[neg_rule]
    neg_y <- y[neg_rule]
    vR <- values_to_range (neg_x, neg_y, rtRange)
    points (vR$x, vR$y, col=neg_point[[2]], pch=neg_point[[1]], cex=point_cex[neg_rule])
    
    # Positive control points
    # Only with three parameters in datanames
    if (length(realnames) > 2) {
        pos_rule <- c(pos[datanames$pos_control][[1]] > 0, neg[datanames$pos_control][[1]] > 0)
        pos_x <- x[pos_rule]
        pos_y <- y[pos_rule]
        vR <- values_to_range (pos_x, pos_y, rtRange)        
        points (vR$x, vR$y, col=pos_point[[2]], pch=pos_point[[1]], cex=point_cex[pos_rule])
    }
    
    # Treatment points
    treat_rule <- c(pos[datanames$treatment][[1]] > 0, neg[datanames$treatment][[1]] > 0)
    treat_x <- x[treat_rule]
    treat_y <- y[treat_rule]
    vR <- values_to_range (treat_x, treat_y, rtRange)  
    points (vR$x, vR$y, col=tr_point[[2]], pch=tr_point[[1]], cex=point_cex[treat_rule])  
    
    # Legend
    # In case of three groups
    if (length (realnames) > 2) {
        legend ("topleft", cex=0.7, horiz=FALSE,
                legend=c("Negative control", "Positive control", "Treatment"),
                col=c(neg_point[[2]], pos_point[[2]], tr_point[[2]]), 
                pch=c(neg_point[[1]], pos_point[[1]], tr_point[[1]]))
    }
    # In case of only two groups (negative and treatment)
    else {
        legend ("topleft", cex=0.7, horiz=FALSE,
                legend=c("Negative control", "Treatment"),
                col=c(neg_point[[2]], tr_point[[2]]), 
                pch=c(neg_point[[1]], tr_point[[1]]))   
    }
    if (toPDF) {dev.off()}
}

#' Generic plot function for MS-spectrum
#' 
#' Plot m/z grouped together by specific time. The significance of peaks is 
#' based on the difference between treatment and negative control 
#' (\code{\strong{folds}}) (or if set otherwise in other functions). If other 
#' statistical values are passed, they will be printed next to the peaks
#' 
#' @param mz a numerical vector. Contains negative and positive m/z together
#' @param folds a numerical vector. Each number related to the number in 
#'   \code{mz} parameter. The height of the line.
#' @param RT optional number. Used as a title
#' @param tstat an optional numerical vector. Each number related to the number 
#'   in \code{mz} parameter. Value represents Welch's t test. See \emph{details}
#' @param pvalue pvalue of t-statistic
#' @details Description of \code{\strong{tstat}} in \link[xcms]{diffreport}
#'   function (xcms package): Welch's two sample t-statistic, positive for
#'   analytes having greater intensity in \code{class2}, negative for analytes having
#'   greater intensity in \code{class1}
#' @seealso \code{\link{plot_choosed_rt}}
plot_mz <- function (mz, folds, RT=0, tstat=FALSE, pvalue=FALSE) {
    # Separate positive and negative modes
    sign <- folds / abs (folds)
    # All peaks in one direction (top)
    folds <- abs (folds)
    # To make sure signature will fit
    digit_space <- max(folds, na.rm=TRUE)/10
    
    x_space <- (max(mz) + 1 - min(abs(mz))) / 10
    xrange <- c(min (abs(mz)) - x_space, max (abs(mz)) + x_space)
    
    plot (x=abs(mz),  # Fit negative mode together with positive
          y=folds-(digit_space), # To make sure signature will fit there
          type='n', axes=FALSE,
          ylim=(c(0, max(folds, na.rm=TRUE)+(2.5*digit_space))), # Space for text
          xlim=xrange)#, # Create a little shifts in both sides
    lines (x=abs(mz), y=folds-(folds/10), type='h')
    axis (side=2, line=-2)
    arrows (x0=xrange[1], y0=0, x1=xrange[2], y1=0, length=0.15)
    text (x=xrange[2], y=digit_space, labels="m/z", pos=2)
    
    # Add identification to the plot
    #text (x=xrange[2], 
    #      y=max(folds, na.rm=TRUE) + (digit_space * 0.75), 
    #      pos=2, labels=paste("RT= ", RT, " min"), cex=1.5)
    mtext (paste("RT= ", RT, " min"), side = 3, xpd=NA)
    
    text_l <- paste ("mz=", round (sign*mz, digits=2))
    
    # Add table to plot
    if (tstat && pvalue) {
        text_l <- paste (text_l, "\nt=", round (tstat,2),
                         "\np=", round (pvalue, 2))
    }
    text (x=abs(mz), y=folds + (digit_space*0.8), labels = text_l, cex=1)    
}

#' Combine and plot several MS-specrums
#' 
#' Plot spectrums together on one page. Function is using 
#' \code{\link{combine_ms_data_rt}} to collect data in the right order.
#' 
#' @param pos a list of values after \link[xcms]{diffreport} method and 
#'   postprocessing in gerbiochem package. Positive mode values
#' @param neg a list of values after \link[xcms]{diffreport} method and 
#'   postprocessing in gerbiochem package. Negative mode values
#' @param RTimes a numeric vector containing all retention times (round to one 
#'   minute) for ploting
#' @param max_layer a number value (default is 4). How many graphs should be on 
#'   one page
#' @param toPDF logical (optional, default is \code{FALSE}). Should the plot be 
#'   rendered in pdf device.
#' @param path a path string to the folder. Should specify if \code{toPDF} 
#'   parameter is \code{TRUE}. Does not create folders itself.
#'   
#' @details \code{\strong{path}} If using \code{\link{plot_choosed_rt}} 
#'   directly, check directory first with \code{\link[base]{dir.exists}} and 
#'   create one after with \code{\link[base]{dir.create}} \cr file is produced
#'   under the next rule "all_mz_in_rt_"%FirstRetentionTimeOnThePlot.pdf
#'   
#' @seealso \code{\link{combine_ms_data_rt}}, \code{\link{plot_mz}}
plot_choosed_rt <- function (pos, neg, RTimes, max_layer=4, toPDF=FALSE, path="") {
    def.par <- par(no.readonly = TRUE)
    this_layer=0  
    for (t in RTimes) {
        data <- combine_ms_data_rt (pos[floor (pos$rtmed) == t, ], neg[floor (neg$rtmed) == t, ])
        
        # Check data integrity
        test <- TRUE            
        for (d in data) {
            if (length (d) == 0) test<-FALSE
            if (d[1] == FALSE) test <- FALSE
        }
        if (test == FALSE) {next}    
        
        # Check should we create file for plots
        if (this_layer == 0) {
            if (toPDF & nchar (path) > 0) {
                pdf (file = paste (path, "all_mz_in_rt_", t, ".pdf", sep = ""),
                    bg='white', width=16, height=9) 
            }
            # Create layout
            par (mar = c(0,0,1,0), oma=c(0,0,1,0))
            # Depricated
            #lays <- rbind (c(1), c(2), c(3), c(4))
            lays <- cbind (seq (1, max_layer))
            ns <- layout (mat = lays) 
        }
        
        plot_mz (RT=t, mz=data$mz, folds=data$folds, tstat=data$tstat, pvalue=data$pvalue)
        if (this_layer == 0) {
            #Sometimes title crosses with data value. While it is not fixed I
            #commented this string
            # title ("TIC in RT", line = -2)
        }
        this_layer <- this_layer + 1
        
        # If 4 plots on the image, save file
        if (this_layer > max_layer-1) {
            this_layer <- 0
            if (toPDF) {dev.off()}
        }
    }
    # Reset settings
    #par (def.par)
}


#' Plot chromatogram with radiactivity as a signal
#' 
#' This function shows only bars that was higher then background. Drawing line 
#' showed all fractions
#' 
#' @param activity the vector with data to plot
#' @param method a data.frame with chromatographical method used to produce data
#' @param toPDF an optional logical value. Default is \code{FALSE}. Should the 
#'   plot be rendered in pdf device.
#' @param filename a name of the file without extention (.pdf)
#' @param path an optional string. Path to the folder, where file should be
#'   created. If not specified, file created in working directory. 
#'   
#' @details If \code{path} directs to unexistent folder, a new folder will be
#'   created under this path
plot_activity <- function (activity, method, toPDF=FALSE, filename="", path="/"){
    if (toPDF) {
        filename <- check_path (path, filename, "activity")  
        pdf (file = paste (path, filename, ".pdf", sep = ""), width=16, height=9)
    }
    baseLine <- mean (activity)
    isActive <- activity > baseLine
    dbar <- barplot (height= isActive * activity, col='green', axes = FALSE, 
                     ylim = range (0, round (max (activity), -2)))
    text (x = dbar * isActive, y = (activity * isActive) + 30, 
          labels = 1:length(activity), pos=1, cex = 0.5)
    lines (x=dbar, y=activity, col='grey', lwd=0.5)
    if (toPDF) {dev.off()}
}

