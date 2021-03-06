\name{imgCor}
\encoding{latin1}
\alias{imgCor}


\title{Image Maps of Correlation Matrices between two Data Sets}

\description{
Display two-dimensional visualizations (image maps) of the correlation matrices within and between
two data sets.
}

\usage{
imgCor(X,
Y,
type = "combine",
X.var.names = TRUE,
Y.var.names = TRUE,
sideColors = TRUE,
interactive.dev = TRUE,
title = TRUE,
color, row.cex, col.cex,symkey, keysize,
xlab, ylab, margins, lhei, lwid)
}

\arguments{
  \item{X}{numeric matrix or data frame \eqn{(n} x \eqn{p)}, the observations on the \eqn{X} variables.
    \code{NA}s are allowed.}
  \item{Y}{numeric matrix or data frame \eqn{(n} x \eqn{q)}, the observations on the \eqn{Y} variables.
    \code{NA}s are allowed.}
  \item{type}{character string, (partially) maching one of \code{"combine"} or \code{"separated"}, 
    determining the kind of plots to be produced. See Details.}	
\item{X.var.names, Y.var.names}{logical, should the name of \eqn{X}- and/or \eqn{Y}-variables be shown? If
\code{TRUE} (defaults) \code{object$names$X} and/or \code{object$names$Y} are used. Possible character
vector with \eqn{X}- and/or \eqn{Y}-variable labels to use.}
\item{sideColors}{character vector of length two. The color name for horizontal
and vertical side bars that may be used to annotate the \eqn{X} and \eqn{Y}
correlation matrices.}
\item{interactive.dev}{boolean. The current graphics device that will be opened is interactive?}
\item{title}{logical, should the main titles be shown?}
\item{color,xlab, ylab}{arguments passed to \code{cim}.}
\item{row.cex, col.cex}{positive numbers, used as \code{cex.axis} in for the row or column
axis labeling. The defaults currently only use number of rows or columns, respectively.}
\item{symkey}{boolean indicating whether the color key should be made symmetric about 0.
Defaults to \code{TRUE}.}
\item{keysize}{positive numeric value indicating the size of the color key.}
\item{margins}{numeric vector of length two containing the margins (see \code{\link{par}(mar)})
for column and row names respectively.}
\item{lhei, lwid}{arguments passed to \code{layout} to divide the device up into two
rows and two columns, with the row-heights \code{lhei} and the column-widths \code{lwid}.}
}

\details{
If \code{type="combine"}, the correlation matrix is computed of the combined
matrices \code{cbind(X, Y)} and then plotted. If \code{type="separate"}, 
three correlation matrices are computed, \code{cor(X)}, \code{cor(Y)} and 
\code{cor(X,Y)} and plotted separately on a device. In both cases, 
a color correlation scales strip is plotted.

The correlation matrices are pre-processed before calling the \code{image} 
function in order to get, as in the numerical representation, the diagonal 
from upper-left corner to bottom-right one.

Missing values are handled by casewise deletion in the \code{imgCor} function.

If \code{X.names = FALSE}, the name of each X-variable is hidden. 
Default value is \code{TRUE}.

If \code{Y.names = FALSE}, the name of each Y-variable is hidden. 
Default value is \code{TRUE}.
}

\author{Ignacio Gonzalez.}

\seealso{\code{\link{cor}}, \code{\link{image}}, \code{\link{color.jet}}.}

\examples{
data(nutrimouse)
X <- nutrimouse$lipid
Y <- nutrimouse$gene

## 'combine' type plot (default)
imgCor(X, Y)

## 'separate' type plot
\dontrun{
imgCor(X, Y, type = "separate")

## 'separate' type plot without the name of datas
imgCor(X, Y, X.names = FALSE, Y.names = FALSE, type = "separate")
}
}

\keyword{multivariate}
\keyword{dplot}
