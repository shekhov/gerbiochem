% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/plot_data.r
\name{plot_choosed_rt}
\alias{plot_choosed_rt}
\title{Combine and plot several MS-specrums}
\usage{
plot_choosed_rt(pos, neg, RTimes, max_layer = 4, toPDF = FALSE, path = "")
}
\arguments{
\item{pos}{a list of values after \link[xcms]{diffreport} method and
postprocessing in gerbiochem package. Positive mode values}

\item{neg}{a list of values after \link[xcms]{diffreport} method and
postprocessing in gerbiochem package. Negative mode values}

\item{RTimes}{a numeric vector containing all retention times (round to one
minute) for ploting}

\item{max_layer}{a number value (default is 4). How many graphs should be on
one page}

\item{toPDF}{logical (optional, default is \code{FALSE}). Should the plot be
rendered in pdf device.}

\item{path}{a path string to the folder. Should specify if \code{toPDF}
  parameter is \code{TRUE}. Does not create folders itself.}
}
\description{
Plot spectrums together on one page. Function is using
\code{\link{combine_ms_data_rt}} to collect data in the right order.
}
\details{
\code{\strong{path}} If using \code{\link{plot_choosed_rt}}
  directly, check directory first with \code{\link[base]{dir.exists}} and
  create one after with \code{\link[base]{dir.create}} \cr file is produced
  under the next rule "all_mz_in_rt_"%FirstRetentionTimeOnThePlot.pdf
}
\seealso{
\code{\link{combine_ms_data_rt}}, \code{\link{plot_mz}}
}

