\name{nearZeroVar}
\encoding{latin1}
\alias{nearZeroVar}

\title{Identification of zero- or near-zero variance predictors}

\description{
Borrowed from the \pkg{caret} package. It is used as an internal function in the PLS methods, but ca n also be used as an extermnal function, in particular when the data contain a lot of zeroes values and need to be prefiletered beforehand. 

This function diagnoses predictors that have one unique value (i.e. are zero variance predictors) 
or predictors that are have both of the following characteristics: they have very few unique values 
relative to the number of samples and the ratio of the frequency of the most common value to the 
frequency of the second most common value is large.}

\usage{
nearZeroVar(x, freqCut = 95/5, uniqueCut = 10)
}

\arguments{
  \item{x}{a numeric vector or matrix, or a data frame with all numeric data.}
  \item{freqCut}{the cutoff for the ratio of the most common value to the second most common value.}
  \item{uniqueCut}{the cutoff for the percentage of distinct values out of the number of total samples.}
}

\details{
For example, an example of near zero variance predictor is one that, for
1000 samples, has two distinct values and 999 of them are a single
value.

To be flagged, first the frequency of the most prevalent value over the
second most frequent value (called the ``frequency ratio'') must be
above \code{freqCut}. Secondly, the ``percent of unique values,''  the
number of unique values divided by the total number of samples (times
100), must also be below \code{uniqueCut}.

In the above example, the frequency ratio is 999 and the unique value
percentage is 0.0001.
}

\value{
\code{nearZeroVar} returns a list that contains the following components:

  \item{Position}{a vector of integers corresponding to 
    the column positions of the problematic predictors that will need to be removed.}
  \item{Metrics}{a data frame containing the zero- or near-zero predictors information
    with columns: \code{freqRatio}, the ratio of frequencies 
    for the most common value over the second most common value and, \code{percentUnique}, 
    the percentage of unique data points out of the total number of data points.}
}

\author{Max Kuhn, with speed improvements to nearZerVar by Allan Engelhardt; enhancements by Florian Rohart, and speed up improvements by Benoit Gautier for mixOmics}

\seealso{\code{\link{pls}}, \code{\link{spls}}, \code{\link{plsda}}, \code{\link{splsda}}}



\keyword{utilities}

