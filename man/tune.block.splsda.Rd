\name{tune.block.splsda}
\encoding{latin1}
\alias{tune.block.splsda}


\title{Tuning function for block.splsda method}

\description{
Computes M-fold or Leave-One-Out Cross-Validation scores based on a user-input
grid to determine the optimal parsity parameters values for method \code{block.splsda}.
}

\usage{
tune.block.splsda(X, Y,
indY,
ncomp = 2,
test.keepX,
already.tested.X,
constraint = FALSE,
validation = "Mfold",
folds = 10,
dist = "max.dist",
measure = "BER",
weighted = TRUE,
progressBar = TRUE,
max.iter = 100,
near.zero.var = FALSE,
nrepeat = 1,
design,
scheme,
mode,
scale = TRUE,
bias,
init ,
tol = 1e-06,
verbose,
light.output = TRUE,
cpus,
name.save=NULL
)
}

\arguments{

\item{X}{numeric matrix of predictors. \code{NA}s are allowed.}
\item{Y}{\code{if(method = 'spls')} numeric vector or matrix of continuous responses (for multi-response models) \code{NA}s are allowed.}
\item{indY}{To be supplied if Y is missing, indicates the position of the matrix / vector response in the list \code{X}}
\item{ncomp}{the number of components to include in the model.}
\item{test.keepX}{A list of length the number of blocks in X (without the outcome). Each entry of this list is a numeric vector for the different keepX values to test for that specific block.}

\item{already.tested.X}{Optional, only if \code{ncomp > 1}. A list of length the number of blocks in X (without the outcome). Each entry contains a list of which variables of X are to be kept on each of the first PLS-components (if \code{constraint=TRUE}) or a numeric vector indicating the number of variables to select from the \eqn{X} data set on the firsts components (if \code{constraint = FALSE}), see examples.}

\item{constraint}{Indicate whether the performance of the model should be evaluated w.r.t the number of variables selected (keepX, default constraint = FALSE) or w.r.t the specific variables selected by the model (keepX.constraint, constraint = TRUE), see examples. }
\item{validation}{character.  What kind of (internal) validation to use, matching one of \code{"Mfold"} or
\code{"loo"} (see below). Default is \code{"Mfold"}.}
\item{folds}{the folds in the Mfold cross-validation. See Details.}
\item{dist}{distance metric to use for \code{splsda} to estimate the classification error rate,
should be a subset of \code{"centroids.dist"}, \code{"mahalanobis.dist"} or \code{"max.dist"} (see Details).}
\item{measure}{Two misclassification measure are available: overall misclassification error \code{overall} or the Balanced Error Rate \code{BER}}
\item{weighted}{tune using either the performance of the Majority vote or the Weighted vote.}

\item{progressBar}{by default set to \code{TRUE} to output the progress bar of the computation.}
\item{max.iter}{integer, the maximum number of iterations.}
\item{near.zero.var}{boolean, see the internal \code{\link{nearZeroVar}} function (should be set to TRUE in particular for data with many zero values). Default value is FALSE}
\item{nrepeat}{Number of times the Cross-Validation process is repeated.}
\item{design}{numeric matrix of size (number of blocks in X) x (number of blocks in X) with 0 or 1 values. A value of 1 (0) indicates a relationship (no relationship) between the blocks to be modelled. If \code{Y} is provided instead of \code{indY}, the \code{design} matrix is changed to include relationships to \code{Y}. }
\item{scheme}{Either "horst", "factorial" or "centroid". Default = \code{centroid}, see reference.}
\item{mode}{character string. What type of algorithm to use, (partially) matching
one of \code{"regression"}, \code{"canonical"}, \code{"invariant"} or \code{"classic"}.
See Details. Default = \code{regression}.}
\item{scale}{boleean. If scale = TRUE, each block is standardized
to zero means and unit variances. Default = \code{TRUE}.}
\item{bias}{boleean. A logical value for biaised or unbiaised estimator of the var/cov. Default = \code{FALSE}.}
\item{init}{Mode of initialization use in the algorithm, either by Singular Value Decompostion of the product of each block of X with Y ("svd") or each block independently ("svd.single"). Default = \code{svd}.}
\item{tol}{Convergence stopping value.}
\item{verbose}{if set to \code{TRUE}, reports progress on computing.}

\item{light.output}{if set to FALSE, the prediction/classification of each sample for each of \code{test.keepX} and each comp is returned.}
\item{cpus}{Number of cpus to use when running the code in parallel.}
\item{name.save}{character string for the name of the file to be saved.}

}

\details{


This tuning function should be used to tune the keepX parameters in the \code{block.splsda} function.

M-fold or LOO cross-validation is performed with stratified subsampling where all classes are represented in each fold.

If \code{validation = "Mfold"}, M-fold cross-validation is performed.
The number of folds to generate is to be specified in the argument \code{folds}.

If \code{validation = "loo"}, leave-one-out cross-validation is performed. By default \code{folds} is set to the number of unique individuals.

All combination of test.keepX values are tested. A message informs how many will be fitted on each component for a given test.keepX.

}

\value{
A list that contains:
\item{error.rate}{returns the prediction error for each \code{test.keepX} on each component}
\item{choice.keepX}{returns the number of variables selected (optimal keepX) on each component, for each block.}
\item{choice.keepX.constraint}{returns the variables selected by the optimal keepX on each component, for each block. only if constraint=TRUE.}
\item{error.rate.class}{returns the error rate for each level of \code{Y} and for each component computed with the optimal keepX}

\item{predict}{Prediction values for each sample, each \code{test.keepX}, each comp and each repeat. Only if light.output=FALSE}
\item{class}{Predicted class for each sample, each \code{test.keepX}, each comp and each repeat. Only if light.output=FALSE}

\item{cor.value}{compute the correlation between latent variables for two-factor sPLS-DA analysis.}
}



\references{
Singh A., Gautier B., Shannon C., Vacher M., Rohart F., Tebbutt S. and Le Cao K.A. (2016).
DIABLO - multi omics integration for biomarker discovery. BioRxiv available here: \url{http://biorxiv.org/content/early/2016/08/03/067611}
}


\author{Florian Rohart, Amrit Singh, Kim-Anh Le Cao.}

\seealso{\code{\link{block.splsda}} and http://www.mixOmics.org for more details.}

\examples{

\dontrun{
data("breast.TCGA")
# this is the X data as a list of mRNA and miRNA; the Y data set is a single data set of proteins
data = list(mrna = breast.TCGA$data.train$mrna, mirna = breast.TCGA$data.train$mirna,
protein = breast.TCGA$data.train$protein)
# set up a full design where every block is connected
design = matrix(1, ncol = length(data), nrow = length(data),
dimnames = list(names(data), names(data)))
diag(design) =  0
design
# set number of component per data set
ncomp = 2

# Tuning the first two components
# -------------

# definition of the keepX value to be tested for each block mRNA miRNA and protein
# names of test.keepX must match the names of 'data'
test.keepX = list(mrna = seq(10,100,20), mirna = seq(10,100,10), protein = seq(1,20,5))

# the following may take some time to run, note that for through tuning
# nrepeat should be > 1
tune = tune.block.splsda(X = data, Y = breast.TCGA$data.train$subtype,
ncomp = ncomp, test.keepX = test.keepX, design = design, nrepeat = 1)

tune$choice.keepX.constraint # NULL as constraint = FALSE per default
tune$choice.keepX

# using constraint = TRUE
tune = tune.block.splsda(X = data, Y = breast.TCGA$data.train$subtype,
ncomp = ncomp, test.keepX = test.keepX, design = design, constraint = TRUE)

tune$choice.keepX.constraint
tune$choice.keepX


# Only tuning the second component
# -------------

constraint.mrna = 4 # 4 variables selected on comp1 for mrna
constraint.mirna  = 2 # 2 variables selected on comp1 for mirna
constraint.prot  = 1 # 1 variables selected on comp1 for protein

already.tested.X = list(mrna = constraint.mrna, mirna = constraint.mirna, prot = constraint.prot)

tune = tune.block.splsda(X = data, Y = breast.TCGA$data.train$subtype,
ncomp = ncomp, test.keepX = test.keepX, design = design,
already.tested.X = already.tested.X, constraint = FALSE)

tune$choice.keepX.constraint # NULL as constraint = FALSE
tune$choice.keepX



# with constraint
## we force the first PLS-component of each block to be built with only a few specific variables

constraint.mrna = list(comp1 = c("EPHB3", "CBR1", "BSPRY"))
constraint.mirna  = list(comp1 = c("hsa-mir-128-2", "hsa-mir-196b"))
constraint.prot  = list(comp1 = c("Paxillin"))

# names of already.tested.X must match the names of 'data'
already.tested.X = list(mrna = constraint.mrna, mirna = constraint.mirna, protein = constraint.prot)

tune = tune.block.splsda(X = data, Y = breast.TCGA$data.train$subtype,
ncomp = ncomp, test.keepX = test.keepX, design = design,
already.tested.X = already.tested.X, constraint = TRUE)

tune$choice.keepX.constraint
tune$choice.keepX


}

}

\keyword{regression}
\keyword{multivariate}
