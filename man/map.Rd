\name{map}
\alias{map}
\title{Classification given Probabilities}

\description{
Converts a matrix in which each row sums to \emph{1}
into the nearest matrix of \emph{(0,1)} indicator variables.
}
\usage{
  map(Y)
}
\arguments{
\item{Y}{
A matrix (for example a matrix of conditional
probabilities  in which each row sums to 1).
}
}
\value{
A integer vector with one entry for each row of Y,
in which the \emph{i}-th value is the column index at which the
\emph{i}-th row of \code{Y} attains a maximum.

}\section{References}{
  C. Fraley and A. E. Raftery (2002).
  Model-based clustering, discriminant analysis, and density estimation.
  \emph{Journal of the American Statistical Association 97:611-631}. 
  
  C. Fraley, A. E. Raftery, T. B. Murphy and L. Scrucca (2012).
  mclust Version 4 for R: Normal Mixture Modeling for Model-Based 
  Clustering, Classification, and Density Estimation. 
  Technical Report No. 597, Department of Statistics, University of Washington.
}
\seealso{
\code{\link{unmap}}
}

\examples{
data(nutrimouse)
Y = unmap(nutrimouse$diet)

map(Y)
}
