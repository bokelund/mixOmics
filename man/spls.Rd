\name{spls}
\encoding{latin1}
\alias{spls}

\title{Sparse Partial Least Squares (sPLS)}

\description{Function to perform sparse Partial Least Squares (sPLS). The sPLS approach
combines both integration and variable selection simultaneously on two data sets
in a one-step strategy.
}

\usage{
spls(X,
Y,
ncomp = 2,
mode = c("regression", "canonical", "invariant", "classic"),
keepX.constraint=NULL,
keepY.constraint=NULL,
keepX,
keepY,
scale = TRUE,
tol = 1e-06,
max.iter = 100,
near.zero.var = FALSE,
logratio="none", 
multilevel=NULL)
}	

\arguments{
  \item{X}{numeric matrix of predictors. \code{NA}s are allowed.}
  \item{Y}{numeric vector or matrix of responses (for multi-response models). 
    \code{NA}s are allowed. For multilevel analysis, a data frame of up to two columns is accepted.}
  \item{ncomp}{the number of components to include in the model (see Details). 
    Default is set to from one to the rank of \code{X}.}
\item{mode}{character string. What type of algorithm to use, (partially) matching
one of \code{"regression"}, \code{"canonical"}, \code{"invariant"} or \code{"classic"}.
See Details.}
\item{keepX.constraint}{A list containing which variables of X are to be kept on each of the first PLS-components}
\item{keepY.constraint}{A list containing which variables of Y are to be kept on each of the first PLS-components}
\item{keepX}{numeric vector of length \code{ncomp}, the number of variables
to keep in \eqn{X}-loadings. By default all variables are kept in the model.}
\item{keepY}{numeric vector of length \code{ncomp}, the number of variables
to keep in \eqn{Y}-loadings. By default all variables are kept in the model.}
\item{scale}{boleean. If scale = TRUE, each block is standardized
to zero means and unit variances (default: TRUE)}
\item{tol}{Convergence stopping value.}
\item{max.iter}{integer, the maximum number of iterations.}
\item{near.zero.var}{boolean, see the internal \code{\link{nearZeroVar}} function (should be set to TRUE in particular for data with many zero values). Setting this argument to FALSE (when appropriate) will speed up the computations. Default value is FALSE}
\item{logratio}{one of ('none','CLR'). Default to 'none'}
\item{multilevel}{Design matrix for repeated measurement analysis, where multlevel decomposition is required. For a one factor decomposition, the repeated measures on each individual, i.e. the individuals ID is input as the first column. For a 2 level factor decomposition then 2nd AND 3rd columns indicate those factors. See examples.}
}

\details{
\code{spls} function fit sPLS models with \eqn{1, \ldots ,}\code{ncomp} components. 
Multi-response models are fully supported. The \code{X} and \code{Y} datasets
can contain missing values.

The type of algorithm to use is specified with the \code{mode} argument. Four PLS
algorithms are available: PLS regression \code{("regression")}, PLS canonical analysis
\code{("canonical")}, redundancy analysis \code{("invariant")} and the classical PLS
algorithm \code{("classic")} (see References).

The estimation of the missing values can be performed 
by the reconstitution of the data matrix using the \code{nipals} function. Otherwise, missing 
values are handled by casewise deletion in the \code{spls} function without having to 
delete the rows with missing data.

logratio transform and multilevel analysis are performed sequentially as internal pre-processing step, through \code{\link{logratio.transfo}} and \code{\link{withinVariation}} respectively.

Multilevel sPLS enables the integration of data measured on two different data sets 
on the same individuals. This approach differs from multilevel sPLS-DA as the aim is 
to select subsets of variables from both data sets that are highly positively or negatively correlated across samples. The approach is unsupervised, i.e. no prior knowledge about the sample groups is included.
}



\value{
\code{spls} returns an object of class \code{"spls"}, a list 
that contains the following components:

  \item{X}{the centered and standardized original predictor matrix.}
  \item{Y}{the centered and standardized original response vector or matrix.}
  \item{ncomp}{the number of components included in the model.}
  \item{mode}{the algorithm used to fit the model.}
  \item{keepX}{number of \eqn{X} variables kept in the model on each component.}
  \item{keepY}{number of \eqn{Y} variables kept in the model on each component.}
  \item{mat.c}{matrix of coefficients to be used internally by \code{predict}.}
  \item{variates}{list containing the variates.}
  \item{loadings}{list containing the estimated loadings for the \eqn{X} and 
	\eqn{Y} variates.}
  \item{names}{list containing the names to be used for individuals and variables.}
  \item{nzv}{list containing the zero- or near-zero predictors information.}
  \item{tol}{the tolerance used in the iterative algorithm, used for subsequent S3 methods}
  \item{max.iter}{the maximum number of iterations, used for subsequent S3 methods}
\item{iter}{Number of iterations of the algorthm for each component}

}

\references{

Le Cao, K.-A., Martin, P.G.P., Robert-Granie, C. and Besse, P. (2009). Sparse canonical methods for biological data integration: application to a cross-platform study. \emph{BMC Bioinformatics} \bold{10}:34.

Le Cao, K.-A., Rossouw, D., Robert-Granie, C. and Besse, P. (2008). A sparse PLS for variable 
selection when integrating Omics data. \emph{Statistical Applications in Genetics and Molecular 
Biology} \bold{7}, article 35.

Shen, H. and Huang, J. Z. (2008). Sparse principal component analysis via regularized 
low rank matrix approximation. \emph{Journal of Multivariate Analysis} \bold{99}, 1015-1034.    

Tenenhaus, M. (1998). \emph{La regression PLS: theorie et pratique}. Paris: Editions Technic.

Wold H. (1966). Estimation of principal components and related models by iterative least squares. 
In: Krishnaiah, P. R. (editors), \emph{Multivariate Analysis}. Academic Press, N.Y., 391-420.

On multilevel analysis:

Liquet, B., Le Cao, K.-A., Hocini, H. and Thiebaut, R. (2012) A novel approach for
biomarker selection and the integration of repeated measures experiments from two
platforms. \emph{BMC Bioinformatics} \bold{13}:325.

Westerhuis, J. A., van Velzen, E. J., Hoefsloot, H. C., and Smilde, A. K. (2010). Multivariate paired data analysis: multilevel PLSDA versus OPLSDA. \emph{Metabolomics},
\bold{6}(1), 119-128.
}

\author{Sebastien Dejean, Ignacio Gonzalez and Kim-Anh Le Cao.}

\seealso{\code{\link{pls}}, \code{\link{summary}}, 
\code{\link{plotIndiv}}, \code{\link{plotVar}}, 
\code{\link{cim}}, \code{\link{network}}, \code{\link{predict}}, \code{\link{perf}} and http://www.mixOmics.org for more details.}

\examples{
data(liver.toxicity)
X <- liver.toxicity$gene
Y <- liver.toxicity$clinic

toxicity.spls <- spls(X, Y, ncomp = 2, keepX = c(50, 50), 
                      keepY = c(10, 10))

## Second example: one-factor multilevel analysis with sPLS, selecting a subset of variables
#--------------------------------------------------------------
\dontrun{
data(liver.toxicity)
# note: we made up those data, pretending they are repeated measurements
repeat.indiv <- c(1, 2, 1, 2, 1, 2, 1, 2, 3, 3, 4, 3, 4, 3, 4, 4, 5, 6, 5, 5,
6, 5, 6, 7, 7, 8, 6, 7, 8, 7, 8, 8, 9, 10, 9, 10, 11, 9, 9,
10, 11, 12, 12, 10, 11, 12, 11, 12, 13, 14, 13, 14, 13, 14,
13, 14, 15, 16, 15, 16, 15, 16, 15, 16)
summary(as.factor(repeat.indiv)) # 16 rats, 4 measurements each

# this is a spls (unsupervised analysis) so no need to mention any factor in design
# we only perform a one level variation split
design <- data.frame(sample = repeat.indiv)
res.spls.1level <- spls(X = liver.toxicity$gene,
Y=liver.toxicity$clinic,
multilevel = design,
ncomp = 3,
keepX = c(50, 50, 50), keepY = c(5, 5, 5),
mode = 'canonical')

# set up colors and pch for plotIndiv
col.stimu <- 1:nlevels(design$stimu)

plotIndiv(res.spls.1level, rep.space = 'X-variate', ind.names = FALSE,
group = liver.toxicity$treatment$Dose.Group,
pch = 20, main = 'Gene expression subspace',
legend = TRUE)


plotIndiv(res.spls.1level, rep.space = 'Y-variate', ind.names = FALSE,
group = liver.toxicity$treatment$Dose.Group,
pch = 20, main = 'Clinical measurements ssubpace',
legend = TRUE)

plotIndiv(res.spls.1level, rep.space = 'XY-variate', ind.names = FALSE,
group = liver.toxicity$treatment$Dose.Group,
pch = 20, main = 'Both Gene expression and Clinical subspaces',
legend = TRUE)
}

## Third example: two-factor multilevel analysis with sPLS, selecting a subset of variables
#--------------------------------------------------------------
\dontrun{
  data(liver.toxicity)
  dose <- as.factor(liver.toxicity$treatment$Dose.Group)
  time <- as.factor(liver.toxicity$treatment$Time.Group)
  # note: we made up those data, pretending they are repeated measurements
  repeat.indiv <- c(1, 2, 1, 2, 1, 2, 1, 2, 3, 3, 4, 3, 4, 3, 4, 4, 5, 6, 5, 5,
                    6, 5, 6, 7, 7, 8, 6, 7, 8, 7, 8, 8, 9, 10, 9, 10, 11, 9, 9,
                    10, 11, 12, 12, 10, 11, 12, 11, 12, 13, 14, 13, 14, 13, 14,
                    13, 14, 15, 16, 15, 16, 15, 16, 15, 16)
  summary(as.factor(repeat.indiv)) # 16 rats, 4 measurements each
  design <- data.frame(sample = repeat.indiv, dose = dose, time = time)

  res.spls.2level = spls(liver.toxicity$gene,
                    Y = liver.toxicity$clinic,
                    multilevel = design,
                    ncomp=2,
                    keepX = c(10,10), keepY = c(5,5))
}


}

\keyword{regression}
\keyword{multivariate}
