\encoding{latin1}
\name{plot.perf}
\alias{plot.perf}
\alias{plot.perf.pls.mthd}
\alias{plot.perf.spls.mthd}
\alias{plot.perf.plsda.mthd}
\alias{plot.perf.splsda.mthd}
\alias{plot.perf.mint.plsda.mthd}
\alias{plot.perf.mint.splsda.mthd}
\alias{plot.perf.sgccda.mthd}

\title{Plot for model performance}

\description{
Function to plot performance criteria, such as MSEP, RMSEP, \eqn{R^2}, \eqn{Q^2} for s/PLS methods, and classification performance for supervised methods, as a
function of the number of components.
}

\usage{
\method{plot}{perf.spls.mthd}(x,
criterion = "MSEP",
xlab = "number of components",
ylab = NULL,
LimQ2 = 0.0975,
LimQ2.col = "darkgrey",
cTicks = NULL,
layout = NULL,
\dots)

\method{plot}{perf.splsda.mthd}(x,
dist = c("all","max.dist","centroids.dist","mahalanobis.dist"),
measure = c("all","overall","BER"),
col,
xlab = NULL,
ylab = NULL,
overlay=c("all", "measure", "dist"),
legend.position=c("vertical", "horizontal"),
sd = TRUE,
\dots)

\method{plot}{perf.mint.splsda.mthd}(x,
dist = c("all","max.dist","centroids.dist","mahalanobis.dist"),
measure = c("all","overall","BER"),
col,
xlab = NULL,
ylab = NULL,
study = "global",
overlay= c("all", "measure", "dist"),
legend.position=c("vertical", "horizontal"),
\dots)

\method{plot}{perf.sgccda.mthd}(x,
dist = c("all","max.dist","centroids.dist","mahalanobis.dist"),
measure = c("all","overall","BER"),
col,
weighted = TRUE,
xlab = NULL,
ylab = NULL,
overlay= c("all", "measure", "dist"),
legend.position=c("vertical","horizontal"),
\dots)
}

\arguments{
  \item{x}{an \code{perf} object.}
  \item{criterion}{character string. What type of validation criterion to plot for 
    \code{pls} or \code{spls}. One of \code{"MSEP"}, \code{"RMSEP"}, \code{"R2"} or \code{"Q2"}. 
	See \code{\link{perf}}.}
  \item{dist}{prediction method applied in \code{perf} for \code{plsda} or \code{splsda}. 
	See \code{\link{perf}}.}
\item{measure}{Two misclassification measure are available: overall misclassification error \code{overall} or the Balanced Error Rate \code{BER}}
\item{col}{character (or symbol) color to be used, possibly vector. One color per distance \code{dist}.}
\item{weighted}{plot either the performance of the Majority vote or the Weighted vote.}
\item{study}{Indicates which study-specific outputs to plot. A character vector containing some levels of \code{object$study}, "all.partial" to plot all studies or "global" is expected. Default to "global".}
\item{overlay}{parameter to overlay graphs; if 'all', only one graph is shown with all outputs; if 'measure', a graph is shown per distance; if 'dist', a graph is shown per measure.}
\item{legend.position}{position of the legend, one of "vertical" (only one column) or "horizontal" (two columns). }

\item{xlab, ylab}{titles for \eqn{x} and \eqn{y} axes.  Typically character strings,
    but can be expressions (e.g., \code{expression(R^2)}).}
  \item{LimQ2}{numeric value. Signification limit for the components in the model. 
    Default is \code{LimQ2 = 0.0975}.}
  \item{LimQ2.col}{character string specifying the color for the \code{LimQ2} line to be plotted.
  If \code{"none"} the line will not be plotted.
  }	
  \item{cTicks}{integer vector. Axis tickmark locations for the used number of components.
    Default is \code{1:ncomp} (see \code{\link{perf}}).}
  \item{layout}{numeric vector of length two giving the number of rows and columns in a 
    multi panel display. If not specified, \code{plot.perf} tries to be intelligent.}


\item{sd}{If 'nrepeat' was used in the call to 'perf', error bar shows the standard deviation if sd=TRUE}
  \item{\dots}{Further arguments sent to \code{\link{xyplot}} function.}
}

\details{
\code{plot.perf} creates one plot for each response variable in the
model, laid out in a multi panel display.  It uses \code{\link{xyplot}} for
performing the actual plotting.
}

\author{Ignacio Gonzalez, Florian Rohart, Francois Bartolo, Kim-Anh Le Cao.}

\seealso{\code{\link{pls}}, \code{\link{spls}}, \code{\link{plsda}}, \code{\link{splsda}}, 
\code{\link{perf}}.}

\examples{
require(lattice)

## validation for objects of class 'pls' or 'spls'
\dontrun{
data(liver.toxicity)
X <- liver.toxicity$gene
Y <- liver.toxicity$clinic

liver.pls <- pls(X, Y, ncomp = 3)
liver.perf <- perf(liver.pls, validation = "Mfold")
				   
plot(liver.perf, criterion = "R2", layout = c(2, 2))
}

## validation for objects of class 'plsda' or 'splsda'
\dontrun{
data(breast.tumors)
X <- breast.tumors$gene.exp
# Y will be transformed as a factor in the function,
# but we set it as a factor to set up the colors.
Y <- as.factor(breast.tumors$sample$treatment)

res <- splsda(X, Y, ncomp = 2, keepX = c(25, 25))
breast.perf <- perf(res, nrepeat = 5)

plot(breast.perf)
plot(breast.perf, col=1:3)
plot(breast.perf, col=1:3, sd=FALSE)

}
}

\keyword{regression}
\keyword{multivariate}
\keyword{hplot}
