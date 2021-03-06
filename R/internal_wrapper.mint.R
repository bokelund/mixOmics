#############################################################################################################
# Author :
#   Florian Rohart, The University of Queensland, The University of Queensland Diamantina Institute, Translational Research Institute, Brisbane, QLD
#
# created: 22-04-2015
# last modified: 08-07-2016
#
# Copyright (C) 2015
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#############################################################################################################


# ========================================================================================================
# internal_wrapper.mint: perform a vertical PLS on a combination of experiments, input as a matrix in X
# this function is a particular setting of internal_mint.block, the formatting of the input is checked in Check.entry.pls
# internal function. Do not export in NAMESPACE.
# ========================================================================================================
# used in (mint).(s)pls(da)

# X: numeric matrix of predictors
# Y: numeric vector or matrix of responses
# ncomp: the number of components to include in the model. Default to 2.
# study: grouping factor indicating which samples are from the same study
# keepX.constraint: A list containing which variables of X are to be kept on each of the first PLS-components.
# keepY.constraint: A list containing which variables of Y are to be kept on each of the first PLS-components
# keepX: number of \eqn{X} variables kept in the model on the last components (once all keepX.constraint[[i]] are used).
# keepY: number of \eqn{Y} variables kept in the model on the last components.
# mode: input mode, one of "canonical", "classic", "invariant" or "regression". Default to "regression"
# scale: boleean. If scale = TRUE, each block is standardized to zero means and unit variances (default: TRUE).
# near.zero.var: boolean, see the internal \code{\link{nearZeroVar}} function (should be set to TRUE in particular for data with many zero values). Setting this argument to FALSE (when appropriate) will speed up the computations
# max.iter: integer, the maximum number of iterations.
# tol: Convergence stopping value.
# logratio: one of "none", "CLR"
# DA: indicate whether it's a DA analysis, only used for the multilvel approach with withinVariation
# multilevel: multilevel is passed to multilevel(design=) in withinVariation. Y is ommited and should be included in multilevel design

internal_wrapper.mint = function(X,
Y,
study,
ncomp = 2,
keepX.constraint,
keepY.constraint,
keepX,
keepY,
mode,
scale = FALSE,
near.zero.var = FALSE,
max.iter = 100,
tol = 1e-06,
logratio = "none",   # one of "none", "CLR"
DA = FALSE,           # indicate whether it's a DA analysis, only used for the multilvel approach with withinVariation
multilevel = NULL)    # multilevel is passed to multilevel(design=) in withinVariation. Y is ommited and should be included in multilevel design
{
    
    if (is.null(ncomp) || !is.numeric(ncomp) || ncomp <= 0 || length(ncomp)>1)
    stop("invalid number of variates, 'ncomp'.")
    
    #-- validation des arguments --#
   
    check = Check.entry.pls(X, Y, ncomp, keepX, keepY, keepX.constraint, keepY.constraint, mode=mode, scale=scale,
    near.zero.var=near.zero.var, max.iter=max.iter ,tol=tol ,logratio=logratio ,DA=DA, multilevel=multilevel)
    X = check$X
    input.X = X # save the checked X, before logratio/multileve/scale
    Y = check$Y
    ncomp = check$ncomp
    mode = check$mode
    keepX.constraint = check$keepX.constraint
    keepY.constraint = check$keepY.constraint
    keepX = check$keepX
    keepY = check$keepY
    nzv.A = check$nzv.A

    #set the default study factor
    if (missing(study))
    {
        study = factor(rep(1,nrow(X)))
    } else {
        study = as.factor(study)
    }
    if (length(study) != nrow(X))
    stop(paste0("'study' must be a factor of length ",nrow(X),"."))
    
    if (any(table(study) <= 1))
    stop("At least one study has only one sample, please consider removing before calling the function again")
    if (any(table(study) < 5))
    warning("At least one study has less than 5 samples, mean centering might not do as expected")
    
    design = matrix(c(0,1,1,0), ncol = 2, nrow = 2, byrow = TRUE)

      
    #-----------------------------#
    #-- logratio transformation --#
    
    X = logratio.transfo(X=X, logratio=logratio)
    
    #as X may have changed
    if (ncomp > min(ncol(X), nrow(X)))
    stop("'ncomp' should be smaller than ", min(ncol(X), nrow(X)), call. = FALSE)
    
    #-- logratio transformation --#
    #-----------------------------#
    
    
    #---------------------------------------------------------------------------#
    #-- multilevel approach ----------------------------------------------------#
    
    if (!is.null(multilevel))
    {
        if (!DA)
        {
            Xw = withinVariation(X, design = multilevel)
            Yw = withinVariation(Y, design = multilevel)
            X = Xw
            Y = Yw
        } else {
            Xw = withinVariation(X, design = multilevel)
            X = Xw
            
            #-- Need to set Y variable for 1 or 2 factors
            Y = multilevel[, -1,drop=FALSE]
            if (ncol(Y)>0)
            Y = apply(Y, 1, paste, collapse = ".")  #  paste is to combine in the case we have 2 levels
            
            Y = as.factor(Y)
            Y.factor = Y
            Y = unmap(Y)
            colnames(Y) = levels(Y)
            rownames(Y) = rownames(X)
            # if DA keepY should be all the levels (which is not happening in the check because of multilevel
            keepY = rep(ncol(Y),ncomp)
        }
    }
    #-- multilevel approach ----------------------------------------------------#
    #---------------------------------------------------------------------------#


    #---------------------------------------------------------------------------#
    #-- pls approach ----------------------------------------------------#
    
    result = internal_mint.block(A = list(X = X, Y = Y), indY = 2, mode = mode, ncomp = c(ncomp, ncomp), tol = tol, max.iter = max.iter,
    design = design, keepA = list(keepX, keepY), keepA.constraint = list(keepX.constraint, keepY.constraint),
    scale = scale, scheme = "horst",init="svd", study = study)
    
    #-- pls approach ----------------------------------------------------#
    #---------------------------------------------------------------------------#

    result$ncomp = ncomp
    if(near.zero.var)
    result$nzv = nzv.A
    
    if(!is.null(multilevel) & DA)
    result$Y.factor = Y.factor

    result$input.X = input.X
    
    class(result) = c("mint.spls.hybrid")
    return(invisible(result))
    
}



