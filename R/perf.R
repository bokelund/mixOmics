#############################################################################################################
# Authors:
#   Ignacio Gonzalez, Genopole Toulouse Midi-Pyrenees, France
#   Kim-Anh Le Cao, The University of Queensland, The University of Queensland Diamantina Institute, Translational Research Institute, Brisbane, QLD
#   Benoit Gautier, The University of Queensland, The University of Queensland Diamantina Institute, Translational Research Institute, Brisbane, QLD
#   Florian Rohart, The University of Queensland, The University of Queensland Diamantina Institute, Translational Research Institute, Brisbane, QLD
#   Francois Bartolo, Institut National des Sciences Appliquees et Institut de Mathematiques, Universite de Toulouse et CNRS (UMR 5219), France
#
# created: 2015
# last modified: 24-08-2016
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


# --------------------------
# declare the S3 function:
# -------------------------
perf = function(object, ...) UseMethod("perf")


#------------------------------------------------------#
#-- Includes perf for PLS, sPLS, PLS-DA and sPLS-DA --#
#------------------------------------------------------#

#---------------------------------------------------
# perf for spls and pls object
#---------------------------------------------------

perf.spls  = perf.pls = function(object,
validation = c("Mfold", "loo"),
folds = 10,
progressBar = TRUE,
...)
{
    #------------------#
    #-- check entries --#
    
    #-- check spls mode
    if (object$mode == 'canonical')
    stop("object$mode should be 'regression', 'invariant' or 'classic'.", call. = FALSE)
    
    #-- validation
    choices = c("Mfold", "loo")
    validation = choices[pmatch(validation, choices)]
    
    if (any(is.na(validation)) || length(validation) > 1)
    stop("'validation' should be one of 'Mfold' or 'loo'.", call. = FALSE)
    
    #-- progressBar
    if (!is.logical(progressBar))
    stop("'progressBar' must be a logical constant (TRUE or FALSE).", call. = FALSE)
    
    #-- end checking --#
    #------------------#
    
    
    #-- cross-validation approach  ---------------------------------------------#
    #---------------------------------------------------------------------------#
    
    #-- initialising arguments --#
    # these are the centered and scaled matrices output from pls, we remove $nzv if needed
    if (length(object$nzv$Position)>0)
    {
        X = object$X[, -object$nzv$Position]
    } else {
        X = object$X
    }
    Y = object$Y
    
    
    tol = object$tol
    max.iter = object$max.iter
    mode = object$mode
    ncomp = object$ncomp
    n = nrow(X)
    p = ncol(X)
    q = ncol(Y)
    res = list()
    
    if (any(is.na(X)) || any(is.na(Y)))
    stop("missing data in 'X' and/or 'Y'. Use 'nipals' for dealing with NAs.", call. = FALSE)
    
    
    #-- tells which variables are selected in X and in Y --#
    if (any(class(object) == "spls"))
    {
        keepX = object$keepX
        keepY = object$keepY
    } else {
        keepX = rep(ncol(X), ncomp)
        keepY = rep(ncol(Y), ncomp)
    }
    
    #-- define the folds --#
    if (validation == "Mfold")
    {
        if (is.list(folds))
        {
            
            if (length(folds) < 2 || length(folds) > n)
            stop("Invalid number of folds.", call. = FALSE)
            
            if (length(unlist(folds)) != n)
            stop("Invalid folds. The total number of samples in folds must be equal to ",
            n, ".", call. = FALSE)
            
            if (length(unique(unlist(folds))) != n)
            stop("Invalid folds. Repeated samples in folds.", call. = FALSE)
            
            M = length(folds)
        } else {
            if (is.null(folds) || !is.finite(folds) || folds < 2 || folds > n)
            {
                stop("Invalid number of folds.", call. = FALSE)
            } else {
                M = round(folds)
                folds = split(sample(1:n), rep(1:M, length = n))
            }
        }
    } else {
        folds = split(1:n, rep(1:n, length = n))
        M = n
    }
    
    #-- set up a progress bar --#
    if (progressBar == TRUE)
    {
        pb = txtProgressBar(style = 3)
        nBar = 1
    }
    
    #-- initialize new objects --#
    RSS = rbind(rep(n - 1, q), matrix(nrow = ncomp, ncol = q))
    PRESS.inside = Q2 = MSEP = R2 = matrix(nrow = ncomp, ncol = q)
    MSEP.mat = Ypred = array(0, c(n, q, ncomp))
    
    press.mat = lapply(1 : ncomp, function(x){matrix(NA, nrow = n, ncol = q)})
    RSS.indiv = lapply(1 : (ncomp + 1), function(x){matrix(NA, nrow = n, ncol = q)})
    RSS.indiv[[1]] = X
    
    #-- record feature stability --#
    # initialize new objects:= to record feature stability
    featuresX  = featuresY =  list()
    for(k in 1:ncomp)
    featuresX[[k]] = featuresY[[k]] = NA
    
    #-- loop on h = ncomp --#
    # the loop is only for the calculation of Q2 on each component
    for (h in 1:ncomp)
    {
        
        #-- initialising arguments --#
        tt = object$variates$X[, h]
        u = object$variates$Y[, h]
        b = object$loadings$Y[, h]
        nx = p - keepX[h]
        ny = q - keepY[h]
        
        #only used for matrices deflation
        c = crossprod(X, tt)/drop(crossprod(tt)) #object$mat.c[, h]
        d = crossprod(Y, tt)/drop(crossprod(tt))#object$mat.d[, h]
        
        RSS.indiv[[h + 1]] = Y - tt %*% t(d)
        RSS[h + 1, ] = colSums((Y - tt %*% t(d))^2)
        
        #-- loop on i (cross validation) --#
        for (i in 1:M)
        {
            if (progressBar == TRUE)
            {
                setTxtProgressBar(pb, nBar/(ncomp * M))
                nBar = nBar + 1
            }
            
            omit = folds[[i]]
            X.train = X[-omit, , drop = FALSE]
            Y.train = Y[-omit, , drop = FALSE]
            X.test = X[omit, , drop = FALSE]
            Y.test = Y[omit, , drop = FALSE]
            u.cv = u[-omit]
            
            
            #-- for MSEP and R2 criteria, no loop on the component as we do a spls with ncomp
            if (h == 1)
            {
                #nzv = (apply(X.train, 2, var) > .Machine$double.eps) # removed in v6.0.0 so that MSEP, R2 and Q2 are obtained with the same data
                spls.res = spls(X.train, Y.train, ncomp = ncomp, mode = mode, max.iter = max.iter, tol = tol, keepX = keepX, keepY = keepY, near.zero.var = FALSE)
                Y.hat = predict(spls.res, X.test)$predict
                
                for (k in 1:ncomp)
                {
                    Ypred[omit, , k] = Y.hat[, , k]
                    MSEP.mat[omit, , k] = (Y.test - Y.hat[, , k])^2
                    
                    # added: record selected features in each set
                    if (any(class(object) == "spls"))
                    {
                        featuresX[[k]] = c(unlist(featuresX[[k]]), selectVar(spls.res, comp = k)$X$name)
                        featuresY[[k]] = c(unlist(featuresY[[k]]), selectVar(spls.res, comp = k)$Y$name)
                    }
                    
                } # end loop on k
            }
            
            #-- Q2 criterion
            a.old.cv = 0
            iter.cv = 1
            
            repeat{
                a.cv = crossprod(X.train, u.cv)
                if (nx != 0)
                {
                    a.cv = ifelse(abs(a.cv) > abs(a.cv[order(abs(a.cv))][nx]),
                    (abs(a.cv) - abs(a.cv[order(abs(a.cv))][nx])) * sign(a.cv), 0)
                }
                a.cv = a.cv / drop(sqrt(crossprod(a.cv)))
                t.cv = X.train %*% a.cv
                
                b.cv = crossprod(Y.train, t.cv)
                if (ny != 0)
                {
                    b.cv = ifelse(abs(b.cv) > abs(b.cv[order(abs(b.cv))][ny]),
                    (abs(b.cv) - abs(b.cv[order(abs(b.cv))][ny])) * sign(b.cv), 0)
                }
                b.cv = b.cv / drop(sqrt(crossprod(b.cv)))
                u.cv = Y.train %*% b.cv
                
                if ((crossprod(a.cv - a.old.cv) < tol) || (iter.cv == max.iter))
                break
                
                a.old.cv = a.cv
                iter.cv = iter.cv + 1
            }
            
            d.cv = t(Y.train) %*% (X.train %*% a.cv) / norm((X.train %*% a.cv), type = "2")^2
            Y.hat.cv = (X.test %*% a.cv) %*% t(d.cv)
            press.mat[[h]][omit, ] = Y.test - Y.hat.cv
            
            
        } # end i (cross validation)
        
        #-- compute the Q2 creterion --#
        PRESS.inside[h, ] = apply(press.mat[[h]], 2, function(x){norm(x, type = "2")^2})
        Q2[h, ] = 1 - PRESS.inside[h, ] / RSS[h, ]
        
        #-- deflation des matrices (for Q2 criterion)
        X = X - tt %*% t(c)
        
        #-- mode classic
        if (mode == "classic")
        Y = Y - tt %*% t(b)
        
        #-- mode regression
        if (mode == "regression")
        Y = Y - tt %*% t(d)
        
        #-- mode invariant: Y is unchanged
        
        #-- compute the MSEP creterion --#
        MSEP[h, ] = apply(as.matrix(MSEP.mat[, , h]), 2, mean)
        
        #-- compute the R2 creterion --#
        R2[h, ] = (diag(cor(object$Y, Ypred[, , h])))^2
        
    } #-- end loop on h --#
    
    if (progressBar == TRUE) cat('\n')
    
    
    #-- output -----------------------------------------------------------------#
    #---------------------------------------------------------------------------#
    Q2.total = matrix(1 - rowSums(PRESS.inside) / rowSums(RSS[-(ncomp+1), , drop = FALSE]), nrow = 1, ncol = ncomp,
    dimnames = list("Q2.total", paste0(1:ncomp, " comp")))
    
    # set up dimnames
    rownames(MSEP) = rownames(R2) = rownames(Q2) = paste0(1:ncomp, " comp")
    colnames(MSEP) = colnames(R2) = colnames(Q2) = object$names$colnames$Y
    
    result = list()
    result$MSEP = t(MSEP)
    result$R2 = t(R2)
    result$Q2 = t(Q2)
   	result$Q2.total =  t(Q2.total)
    result$RSS = RSS
    result$PRESS = PRESS.inside
    result$press.mat = press.mat
    result$RSS.indiv = RSS.indiv
    
    #---- extract stability of features -----#
    if (any(class(object) == "spls"))
    {
        list.features.X = list()
        list.features.Y = list()
        
        for(k in 1:ncomp)
        {
            #remove the NA value that was added for initialisation
            remove.naX = which(is.na(featuresX[[k]]))
            remove.naY = which(is.na(featuresY[[k]]))
            # then summarise as a factor and output the percentage of appearance
            list.features.X[[k]] = sort(table(as.factor(featuresX[[k]][-remove.naX])) / M, decreasing = TRUE)
            list.features.Y[[k]] = sort(table(as.factor(featuresY[[k]][-remove.naY])) / M, decreasing = TRUE)
            
        }
        names(list.features.X)  = names(list.features.Y) = paste('comp', 1:ncomp)
        
        # features
        result$features$stable.X = list.features.X
        result$features$stable.Y = list.features.Y
    }
    
    #--- class
    if (any(class(object) == "spls"))
    {
        method = "spls.mthd"
    } else if (any(class(object) == "pls")) {
        method = "pls.mthd"
    } else {
        warning("Something that should not happen happened. Please contact us.")
    }
    class(result) = c("perf",paste(c("perf", method), collapse ="."))
    result$call = match.call()
    
    return(invisible(result))
}


# ---------------------------------------------------
# perf for plsda and splsda object
# ---------------------------------------------------
perf.splsda = perf.plsda = function(object,
dist = c("all", "max.dist", "centroids.dist", "mahalanobis.dist"),
constraint = FALSE,
validation = c("Mfold", "loo"),
folds = 10,
nrepeat = 1,
auc = FALSE,
progressBar = TRUE,
cpus,
...)
{
    
    #-- initialising arguments --#
    # these data are the centered and scaled X output or the unmapped(Y) scaled and centered
    X = object$input.X
    level.Y = object$names$colnames$Y  #to make sure the levels are ordered
    Y = object$Y
    ncomp = object$ncomp
    n = nrow(X)
    
    logratio = object$logratio
    if (is.null(logratio))
    logratio = "none"
    
    multilevel = object$multilevel # repeated measurement and Y
    near.zero.var = !is.null(object$nzv) # if near.zero.var was used, we set it to TRUE. if not used, object$nzv is NULL
    
    if(any(class(object) == "plsda") & constraint == TRUE)
    {
        constraint = FALSE #no need as all variable will be included
        warning("'constraint' is set to FALSE as all variables are selected on all components (plsda object).")
    }
    #-- tells which variables are selected in X and in Y --#
    if(constraint)
    {
        keepX.constraint = apply(object$loadings$X, 2, function(x){names(which(x!=0))})
        # gives a matrix of ncomp columns, I want a list of length ncomp
        keepX.constraint = split(keepX.constraint, rep(1:ncol(keepX.constraint), each = nrow(keepX.constraint)))
        names(keepX.constraint) = paste("comp",1:length(keepX.constraint),sep="")
        
        #keepX = NULL
    } else {
        #keepX.constraint = NULL
        if (any(class(object) == "splsda"))
        {
            keepX = object$keepX
        } else {
            keepX = rep(ncol(X), ncomp)
        }
    }

    tol = object$tol
    max.iter = object$max.iter
    
    # initialize new objects:
    features = list()
    for(k in 1:ncomp)
    features[[k]] = NA
    
    # check input arguments
    
    if (hasArg(method.predict))
    stop("'method.predict' argument has been replaced by 'dist' to match the 'tune' function")
    method.predict = NULL # to pass R CMD check

    dist = match.arg(dist, choices = c("all", "max.dist", "centroids.dist", "mahalanobis.dist"), several.ok = TRUE)
    if (any(dist == "all"))
    {
        nmthdd = 3
        dist = c("max.dist", "centroids.dist", "mahalanobis.dist")
    } else {
        nmthdd = length(dist)
    }
    
    if (length(validation) > 1 )
    validation = validation [1]
    if (!(validation %in% c("Mfold", "loo")))
    stop("Choose 'validation' among the two following possibilities: 'Mfold' or 'loo'")
    
    if (validation == "loo")
    {
        if (nrepeat != 1)
        warning("Leave-One-Out validation does not need to be repeated: 'nrepeat' is set to '1'.")
        nrepeat = 1
    }
    
    if (!is.logical(progressBar))
    stop("'progressBar' must be either TRUE or FALSE")
    
    measure = c("overall","BER") # one of c("overall","BER")
    
    
    if (!(logratio %in% c("none", "CLR")))
    stop("Choose one of the two following logratio transformation: 'none' or 'CLR'")
    #fold is checked in 'MCVfold'

    if(!missing(cpus))
    {
        if(!is.numeric(cpus) | length(cpus)!=1)
        stop("'cpus' must be a numerical value")
        
        parallel = TRUE
        cl = makeCluster(cpus, type = "SOCK")
        clusterExport(cl, c("splsda","selectVar"))
    } else {
        parallel = FALSE
        cl = NULL
    }
    
    
    #---------------------------------------------------------------------------#
    #-- logration + multilevel approach ----------------------------------------#
    # we can do logratio and multilevel on the whole data as these transformation are done per sample
    X = logratio.transfo(X = X, logratio = logratio)
    if (!is.null(multilevel))
    {
        Xw = withinVariation(X, design = multilevel)
        X = Xw
    }
    #-- logratio + multilevel approach -----------------------------------------#
    #---------------------------------------------------------------------------#


    # -------------------------------------
    # added: first check for near zero var on the whole data set
    if (near.zero.var == TRUE)
    {
        nzv = nearZeroVar(X)
        if (length(nzv$Position > 0))
        {
            warning("Zero- or near-zero variance predictors.\nReset predictors matrix to not near-zero variance predictors.\nSee $nzv for problematic predictors.")
            X = X[, -nzv$Position, drop=TRUE]
            
            if (ncol(X)==0)
            stop("No more predictors after Near Zero Var has been applied!")
            
            if (any(keepX > ncol(X)))
            keepX = ncol(X)
            
        }
    }
    # and then we start from the X data set with the nzv removed
    

    
    list.features = list()

    mat.error.rate = mat.sd.error = mat.mean.error = error.per.class.keepX.opt = list()
    error.per.class = list()
    final=list()
    
    for (measure_i in measure)
    {
        mat.sd.error[[measure_i]] = matrix(0,nrow = ncomp, ncol = length(dist),
        dimnames = list(c(paste('comp', 1 : ncomp)), dist))
        mat.mean.error[[measure_i]] = matrix(0,nrow = ncomp, ncol = length(dist),
        dimnames = list(c(paste('comp', 1 : ncomp)), dist))
        error.per.class.keepX.opt[[measure_i]] = list()
        mat.error.rate[[measure_i]]=list()
        for(ijk in dist)
        {
            mat.error.rate[[measure_i]][[ijk]] = array(0, c(nlevels(Y),  nrepeat ,ncomp),
            dimnames = list(c(levels(Y)),c(paste('nrep', 1 : nrepeat)),c(paste('comp', 1 : ncomp))))

            error.per.class.keepX.opt[[measure_i]][[ijk]] = matrix(nrow = nlevels(Y), ncol = ncomp,
            dimnames = list(c(levels(Y)), c(paste('comp', 1 : ncomp))))
        }
    }
    
    if(auc == TRUE)
    {
        auc.mean=list()
        auc.all=list()
    }
    
    prediction.all = class.all = auc.mean = auc.all = list()
    for(ijk in dist)
    {
        class.all[[ijk]] = array(0, c(nrow(X),  nrepeat ,ncomp),
        dimnames = list(rownames(X),c(paste('nrep', 1 : nrepeat)),c(paste('comp', 1 : ncomp))))
    }

    for (comp in 1 : ncomp)
    {
        if (progressBar == TRUE)
        cat("\ncomp",comp, "\n")
        
        if(constraint)
        {
            
            if(comp > 1)
            {
                choice.keepX.constraint = keepX.constraint[1 : (comp - 1)]
            } else {
                choice.keepX.constraint = NULL
            }
            test.keepX = keepX.constraint[comp]
            #names(test.keepX) = test.keepX
            #test.keepX is a vector a variables to keep on comp 'comp'
        } else {
            if(comp > 1)
            {
                choice.keepX = keepX[1 : (comp - 1)]
            } else {
                choice.keepX = NULL
            }
            test.keepX = keepX[comp]
            names(test.keepX) = test.keepX
            #test.keepX is a value
        }

        # estimate performance of the model for each component
        result = MCVfold.splsda (X, Y, multilevel = multilevel, validation = validation, folds = folds, nrepeat = nrepeat, ncomp = comp,
        choice.keepX = if(constraint){NULL}else{choice.keepX},
        choice.keepX.constraint = if(constraint){choice.keepX.constraint}else{NULL},
        test.keepX = test.keepX, measure = measure, dist = dist, near.zero.var = near.zero.var,
        auc = auc, progressBar = progressBar, class.object = class(object), cl = cl)

        # ---- extract stability of features ----- # NEW
        if (any(class(object) == "splsda"))
        list.features[[comp]] = result$features$stable
       
        for (ijk in dist)
        {
            for (measure_i in measure)
            {
                mat.error.rate[[measure_i]][[ijk]][ ,,comp] = result[[measure_i]]$mat.error.rate[[ijk]][,1]
                mat.mean.error[[measure_i]][comp, ijk]=result[[measure_i]]$error.rate.mean[[ijk]]
                if (!is.null(result[[measure_i]]$error.rate.sd))
                {
                    mat.sd.error[[measure_i]][comp, ijk]=result[[measure_i]]$error.rate.sd[[ijk]]
                } else {
                    mat.sd.error= NULL
                }
                # confusion matrix for keepX.opt
                error.per.class.keepX.opt[[measure_i]][[ijk]][ ,comp]=result[[measure_i]]$confusion[[ijk]][,1]
            }
            
            #prediction of each samples for each fold and each repeat, on each comp
            class.all[[ijk]][, , comp] = result$class.comp[[ijk]][,,1]
        }
        prediction.all[[comp]] = array(unlist(result$prediction.comp),c(nrow(result$prediction.comp[[1]]), ncol(result$prediction.comp[[1]]), nrepeat),
        dimnames = c(dimnames(result$prediction.comp[[1]])[1:2], list(paste0("nrep",1:nrepeat))))#[[1]][, , 1] #take only one component [[1]] and one of test.keepX [,,1]
        
        if(auc == TRUE)
        {
            auc.all[[comp]] = lapply(result$auc.all, function(x) x[,,1])
            auc.mean[[comp]] = result$auc[, , 1]
        }
    }
    if (parallel == TRUE)
    stopCluster(cl)

    names(prediction.all) = paste('comp', 1:ncomp)
    
    result = list(error.rate = mat.mean.error,
    error.rate.sd = mat.sd.error,
    error.rate.all = mat.error.rate,
    error.rate.class = error.per.class.keepX.opt[[1]],
    predict = prediction.all,
    class = class.all)
    
    if(auc)
    {
        names(auc.mean) = c(paste('comp', 1:ncomp))
        result$auc = auc.mean
        
        names(auc.all) = c(paste('comp', 1:ncomp))
        result$auc.all =auc.all
    }

    if (any(class(object) == "splsda"))
    {
        names(list.features) = paste('comp', 1:ncomp)
        result$features$stable = list.features
    }

    if (progressBar == TRUE)
    cat('\n')
    
    # added
    if (near.zero.var == TRUE)
    result$nzvX = nzv$Position
    
    if (any(class(object) == "splsda"))
    {
        method = "splsda.mthd"
    } else if (any(class(object) == "plsda")) {
        method = "plsda.mthd"
    } else {
        warning("Something that should not happen happened. Please contact us.")
    }
    class(result) = c("perf",paste(c("perf", method), collapse ="."))
    result$call = match.call()


    #updated outputs
    return(invisible(result))
}


