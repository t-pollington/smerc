% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prep.results.R
\name{prep.scan}
\alias{prep.scan}
\title{Prepare scan results}
\usage{
prep.scan(tobs, zones, pvalue, coords, cases, pop, ex, longlat, w = NULL,
  d = NULL, a = NULL, shape_all = NULL, angle_all = NULL)
}
\arguments{
\item{tobs}{The observed test statistics for each zone}

\item{zones}{A list of zones}

\item{pvalue}{The p-value associated with each test statistic}

\item{coords}{An \eqn{n \times 2} matrix of centroid
coordinates for the regions.}

\item{cases}{The number of cases observed in each region.}

\item{pop}{The population size associated with each
region.}

\item{ex}{The expected number of cases for each region.
The default is calculated under the constant risk
hypothesis.}

\item{longlat}{The default is \code{FALSE}, which
specifies that Euclidean distance should be used.If
\code{longlat} is \code{TRUE}, then the great circle
distance is used to calculate the intercentroid
distance.}

\item{w}{A binary spatial adjacency matrix for the regions.}

\item{d}{A precomputed distance matrix based on coords}
}
\value{
A scan object
}
\description{
\code{prep.scan} prepares the results of a scan-related
test and turns them into a scan object.
}
\keyword{internal}
