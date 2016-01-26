varpred <- function(mod, varname, frame, isolate=FALSE, isoValue=NULL, level=0.05, steps=101, dfspec=100, vv=NULL){

	print("names(frame)")
	print(names(frame))

	# Service functions
	eff <- function(mod){
		if (inherits(mod, "lm"))
			return (coef(mod))
		return (fixef(mod))
	}
 
	varfun <- function(vcol, steps){
		if(is.numeric(vcol)){
			if(is.null(steps)){return(sort(unique(vcol)))}
			return(seq(min(vcol), max(vcol), length.out=steps))
		}
		return(unique(vcol))
	}
 
	modSelect <- function(f, mod){
		return(f[rownames(model.frame(mod)), ])
	}
 
	# Stats
	mult <- qt(1-level/2, dfspec)
 
	# Eliminate rows that were not used
	rframe <- modSelect(frame, mod)
	names(rframe) <- names(frame)
 
	# Find variable in data frame
	# ISSUE: Can't have a variable name that's a subset of another name
	pat <- paste("\\b", varname, sep="")
	fnames <- names(rframe)
	fCol <- grep(pat, fnames)
	print(pat)
	print(fnames)
	print(paste("Selected variable", fnames[fCol]))
	if(length(fCol)<1) {
		stop(paste("No matches to", varname, "in the frame", collapse=" "))
	}
	if(length(fCol)>1) {
		stop(paste("Too many matches:", fnames[fCol], collapse=" "))
	}
	if(is.null(vv)) {vv <- varfun(rframe[[fCol]], steps)}
	steps <- length(vv)

 
	# Mean row of model matrix
	modTerms <- delete.response(terms(mod))
	mm <- model.matrix(modTerms, rframe)
	rowbar<-matrix(apply(mm, 2, mean), nrow=1)
	mmbar<-rowbar[rep(1, steps), ]
 
	# Find variable in model matrix
	mmNames <- colnames(mm)
	mmCols <- grep(pat, mmNames)
	print(paste(c("Selected columns:", mmNames[mmCols], "from the model matrix"), collapse=" "))
	if (length(mmCols)<1) 
		stop(paste("No matches to", varname, "in the model matrix", collapse=" "))
 
	# Model matrix with progression of focal variable 
	varframe <- rframe[rep(1, steps), ]
	varframe[fCol] <- vv
	mmvar <- mmbar
	print(list(modTerms=modTerms))
	print(list(varframe=varframe))
	mmnew <- model.matrix(modTerms, varframe)
	print(list(mmnew=mmnew))
 
	for(c in mmCols){
		mmvar[, c] <- mmnew[, c]
	}
 
	vc <- vcov(mod)
	if(!identical(colnames(mm), names(eff(mod)))){
		print(setdiff(colnames, names(eff(mod))))
		print(setdiff(names(eff(mod)), colnames))
		stop("Effect names do not match: check for empty factor levels?")
	}
	pred <- mmvar %*% eff(mod)
 
	# (Centered) predictions for SEs
	if (isolate) {
		if(!is.null(isoValue)){
			rframe[fCol] <- 0*rframe[fCol]+isoValue	
			mm <- model.matrix(modTerms, rframe)
			rowbar<-matrix(apply(mm, 2, mean), nrow=1)
			mmbar<-rowbar[rep(1, steps), ]
		}
		mmvar <- mmvar-mmbar
	}
 
	pse_var <- sqrt(diag(mmvar %*% tcrossprod(vc, mmvar)))
 
	df <- data.frame(
		var = vv,
		fit = pred,
		lwr = pred-mult*pse_var,
		upr = pred+mult*pse_var
	)
	names(df)[[1]] <- varname
	return(df)
}

