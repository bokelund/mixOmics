\name{wrapper.rgcca}
\encoding{latin1}
\alias{wrapper.rgcca}

\title{mixOmics wrapper for Regularised Generalised Canonical Correlation Analysis (rgcca)}

\description{Wrapper function to perform Regularized Generalised Canonical Correlation Analysis (rGCCA), a generalised approach for the integration of multiple datasets. For more details, see the \code{help(rgcca)} from the \pkg{RGCCA} package.
}

\usage{	
wrapper.rgcca(data, design = 1 - diag(length(data)), tau = rep(1, length(data)),
  ncomp = rep(1, length(data)), scheme = "centroid", scale = TRUE, init = "svd", 
  bias = TRUE, tol = .Machine$double.eps, verbose = FALSE)
}	

\arguments{
  \item{data}{a list of data sets (called 'blocks') matching on the same samples. Data in the list should be arranged in samples x variables. \code{NA}s are not allowed.}
  \item{design}{numeric matrix of size (number of blocks) x (number of blocks) with only 0 or 1 values. A value of 1 (0) indicates a relationship (no relationship) between the blocks to be modelled using sGCCA.}
  \item{tau}{numeric vector of length the number of blocks in \code{data}. Each regularization parameter will be applied on each block and takes the value between 0 (no regularisation) and 1. If tau = "optimal" the shrinkage paramaters are estimated for each block and
  each dimension using the Schafer and Strimmer (2005)
  analytical formula.}
  \item{ncomp}{numeric vector of length the number of blocks in \code{data}. The number of components to include in the model for each block (does not necessarily takes the same value for each block).}
  \item{scheme}{Either "horst", "factorial" or "centroid"
  (Default: "centroid").}
  \item{scale}{If scale = TRUE, each block is standardized
  to zero means and unit variances (default: TRUE)}
  \item{init}{Mode of initialization use in the SGCCA
  algorithm, either by Singular Value Decompostion ("svd")
  or random ("random") (default : "svd").}
  \item{bias}{A logical value for biaised or unbiaised
  estimator of the var/cov (defaults to TRUE).}
   \item{tol}{Convergence stopping value.}
    \item{verbose}{if set to \code{TRUE}, reports progress on computing.}
}

\details{
	This wrapper function performs rGCCA (see \pkg{RGCCA}) with \eqn{1, \ldots ,}\code{ncomp} components on each block data set.
	A supervised or unsupervised model can be run. For a supervised model, the \code{\link{unmap}} function should be used as an input data set.
	More details can be found on the package \pkg{RGCCA}.
}

\value{
\code{wrapper.rgcca} returns an object of class \code{"rgcca"}, a list 
that contains the following components:

  \item{data}{the input data set (as a list).}
  \item{design}{the input design.}
  \item{variates}{the sgcca components.}
  \item{loadings}{the loadings for each block data set (outer wieght vector).}
  \item{loadings.star}{the laodings, standardised.}
  \item{tau}{the input tau parameter.}
  \item{scheme}{the input schme.}
  \item{ncomp}{the number of components on each block.}
  \item{crit}{the convergence criterion.}
  \item{AVE}{Indicators of model quality based on the
  Average Variance Explained (AVE): AVE(for one block),
  AVE(outer model), AVE(inner model)..}
  \item{names}{list containing the names to be used for individuals and variables.}
  More details can be found in the references.
}

\references{

  Tenenhaus A. and Tenenhaus M., (2011), Regularized
  Generalized Canonical Correlation Analysis,
  Psychometrika, Vol. 76, Nr 2, pp 257-284.
  
  Schafer J. and Strimmer K., (2005), A shrinkage approach
  to large-scale covariance matrix estimation and
  implications for functional genomics. Statist. Appl.
  Genet. Mol. Biol. 4:32.
}

\author{Arthur Tenenhaus, Vincent Guillemot and Kim-Anh L� Cao.}

\seealso{\code{\link{rgcca}}, \code{\link{plotIndiv}}, \code{\link{plotVar}}, \code{\link{wrapper.sgcca}}. \code{\link{sgcca}} and \url{http://www.math.univ-toulouse.fr/~biostat/mixOmics/} for more details.}

\examples{
data(nutrimouse)
# need to unmap the Y factor diet
Y = unmap(nutrimouse$diet)
data = list(nutrimouse$gene, nutrimouse$lipid,Y)
# with this design, gene expression and lipids are connected to the diet factor
# design = matrix(c(0,0,1,
#                   0,0,1,
#                   1,1,0), ncol = 3, nrow = 3, byrow = TRUE)

# with this design, gene expression and lipids are connected to the diet factor
# and gene expression and lipids are also connected
design = matrix(c(0,1,1,
                  1,0,1,
                  1,1,0), ncol = 3, nrow = 3, byrow = TRUE)
#note: the tau parameter is the regularization parameter
wrap.result.rgcca = wrapper.rgcca(data = data, design = design, tau = c(1, 1, 0), 
                                  ncomp = c(2, 2, 1),
                                  scheme = "centroid", verbose = FALSE)
#wrap.result.rgcca
}


\keyword{multivariate}