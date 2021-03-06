\name{mint.block.spls}
\encoding{latin1}
\alias{mint.block.spls}

\title{Horizontal and Vertical sparse integration with variable selection}

\description{Function to integrate data sets measured on the same samples (horizontal integration) and to combine multiple independent studies (vertical integration) using variants of sparse multi-group and generalised PLS with variable selection.
}

\usage{
mint.block.spls(X,
Y,
indY,
study,
ncomp = 2,
keepX.constraint,
keepY.constraint,
keepX,
keepY,
design,
scheme,
mode,
scale = TRUE,
bias,
init ,
tol = 1e-06,
verbose,
max.iter = 100,
near.zero.var = FALSE)

}	

\arguments{
\item{X}{A list of data sets (called 'blocks') measured on the same samples. Data in the list should be arranged in samples x variables, with samples order matching in all data sets.}
\item{Y}{Matrix or vector response for a multivariate regression framework. Data should be continuous variables (see block.splsda for supervised classification and factor reponse)}
\item{indY}{To supply if Y is missing, indicates the position of the matrix / vector response in the list \code{X}}
\item{study}{factor indicating the membership of each sample to each of the studies being combined}
\item{ncomp}{the number of components to include in the model. Default to 2.}
\item{keepX.constraint}{A list of same length as X. Each entry indicates specific variables to be selected in each of the blocks of X for the first PLS-components.}
\item{keepY.constraint}{Only if Y is provided, otherwise extracted from \code{keepX.constraint} (see details). Each entry indicates specific variables to be selected in Y for the first PLS-components.}
\item{keepX}{A list of same length as X.  Each entry is the number of variables to select in each of the blocks of X for each component. In the case where keepX.constraint is specified it should indicate the number of variables to select on the remaining components. By default all variables are kept in the model.}
\item{keepY}{Only if Y is provided. Each entry is the number of variables to select in each of the blocks of Y for each component. In the case where keepX.constraint is specified it should indicate the number of variables to select on the remaining components. By default all variables are kept in the model.}
\item{design}{numeric matrix of size (number of blocks in X) x (number of blocks in X) with 0 or 1 values. A value of 1 (0) indicates a relationship (no relationship) between the blocks to be modelled. If \code{Y} is provided instead of \code{indY}, the \code{design} matrix is changed to include relationships to \code{Y}. }
\item{scheme}{Either "horst", "factorial" or "centroid". Default = \code{horst}, see reference.}
\item{mode}{character string. What type of algorithm to use, (partially) matching
one of \code{"regression"}, \code{"canonical"}, \code{"invariant"} or \code{"classic"}.
See Details.}
\item{scale}{boleean. If scale = TRUE, each block is standardized
to zero means and unit variances (default: TRUE)}
\item{bias}{boleean. A logical value for biaised or unbiaised estimator of the var/cov (defaults to FALSE).}
\item{init}{Mode of initialization use in the algorithm, either by Singular Value Decompostion of the product of each block of X with Y ("svd") or each block independently ("svd.single"). Default = \code{svd.single}.}
\item{tol}{Convergence stopping value.}
\item{verbose}{if set to \code{TRUE}, reports progress on computing.}
\item{max.iter}{integer, the maximum number of iterations.}
\item{near.zero.var}{boolean, see the internal \code{\link{nearZeroVar}} function (should be set to TRUE in particular for data with many zero values). Setting this argument to FALSE (when appropriate) will speed up the computations. Default value is FALSE}
}


\details{
The function fits sparse multi-group generalised PLS models with a specified number of \code{ncomp} components.
An outcome needs to be provided, either by \code{Y} or by its position \code{indY} in the list of blocks \code{X}.

Multi (continuous)response are supported. \code{X} and \code{Y} can contain missing values. Missing values are handled by being disregarded during the cross product computations in the algorithm \code{block.pls} without having to delete rows with missing data. Alternatively, missing data can be imputed prior using the  \code{nipals} function.

The type of algorithm to use is specified with the \code{mode} argument. Four PLS
algorithms are available: PLS regression \code{("regression")}, PLS canonical analysis
\code{("canonical")}, redundancy analysis \code{("invariant")} and the classical PLS
algorithm \code{("classic")} (see References).

}

\value{
\code{mint.block.spls} returns an object of class \code{"mint.spls", "block.spls"}, a list
that contains the following components:

  \item{X}{the centered and standardized original predictor matrix.}
  \item{Y}{the centered and standardized original response vector or matrix.}
\item{ncomp}{the number of components included in the model for each block.}
  \item{mode}{the algorithm used to fit the model.}
  \item{mat.c}{matrix of coefficients to be used internally by \code{predict}.}
  \item{variates}{list containing the \eqn{X} and \eqn{Y} variates.}
  \item{loadings}{list containing the estimated loadings for the variates.}
  \item{names}{list containing the names to be used for individuals and variables.}
  \item{nzv}{list containing the zero- or near-zero predictors information.}
   \item{tol}{the tolerance used in the iterative algorithm, used for subsequent S3 methods}
  \item{max.iter}{the maximum number of iterations, used for subsequent S3 methods}
    \item{iter}{Number of iterations of the algorthm for each component}

}


\references{
F Rohart, A Eslami, S Bougeard and K-A. Lê Cao. MINT: A multivariate integrative approach to identify a reproducible biomarker signature across multiple experiments and platforms. Submitted.

Eslami, A., Qannari, E. M., Kohler, A., and Bougeard, S. (2014). Algorithms for multi-group PLS. J. Chemometrics, 28(3), 192-201.
}

\author{Florian Rohart, Benoit Gautier, Kim-Anh Le Cao}


\seealso{\code{\link{spls}}, \code{\link{summary}},
\code{\link{plotIndiv}}, \code{\link{plotVar}}, \code{\link{predict}}, \code{\link{perf}}, \code{\link{mint.block.pls}}, \code{\link{mint.block.plsda}}, \code{\link{mint.block.splsda}} and http://www.mixOmics.org/mixMINT for more details.}

\examples{
# we will soon provide more examples on our website (data too large to be included in the package
# and still in active development)
}

\keyword{regression}
\keyword{multivariate}
