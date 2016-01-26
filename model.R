## this is in 'already-wrapped' format
L <- load("mergedData2.rda")
options(width=200)
library("glmmTMB")
library("broom")
library("splines")
namedList <- lme4:::namedList

## if necessary
if (FALSE) {
    install.packages("TMB")
    install.packages("dotwhisker")
    library("devtools")
    install_github("glmmTMB/glmmTMB",sub="glmmTMB")
    install_github("bbolker/broom")
}

    hivprev <- read.table(header=TRUE,text="
country HIVprev
Kenya 6.3
Lesotho 23.6
Namibia 14.6
Senegal 0.8
Swaziland 25.8
Uganda 6.3
Zimbabwe 17.8")

dataset <- c(Kenya="KE5",Lesotho="LS5",Namibia="NM5",Senegal="SN4",
             Swaziland="SZ5",Uganda="UG5",Zimbabwe="ZW5")

hivprev$dataset <- dataset[match(hivprev$country,names(dataset))]
          
    
# Make a special data frame for this model

predNames <- c( "knowsPersonHIV", "knowsCondomProtect")

modNames <- c("age", "gender", "urbanRural", "educLevel",
              "wealthRaw", "MrtStat", "religion",
              "AIDSlookHealthy", "whoLastSex")
factNames <- c("province", "clusterId", "dataset")
allNames <- c(predNames, modNames,
              factNames, "condomLastTime")

##  select columns and sub-sample
ModAns <- na.omit(Answers[allNames])

ModAns <- merge(ModAns,hivprev)

nullModForm <- 	condomLastTime	~ ns(age, 4) +
    ns(wealthRaw, 4) +
        gender + 
	urbanRural + 
	educLevel + 
	religion  + 
	MrtStat + 
	AIDSlookHealthy + 
	whoLastSex +
        HIVprev +
	(1|dataset:clusterId) + 
	(1|dataset:province) + 
	(1|dataset)

if (file.exists("models.rda")) {
    L2 <- load("models.rda")
} else {
    null_model <- glmmTMB(nullModForm,family="binomial",
                      data=ModAns)

    knows_model <- update(null_model, . ~
	. + knowsPersonHIV + (0 + knowsPersonHIV | dataset))

    avoid_model <- update(null_model, . ~
	. + knowsCondomProtect + (0 + knowsCondomProtect | dataset))

    base_model <- update(avoid_model, . ~
	. + knowsPersonHIV + (0 + knowsPersonHIV | dataset))

    interaction_model <- update(base_model, . ~
    . +  knowsPersonHIV:knowsCondomProtect +
        (0 + knowsPersonHIV:knowsCondomProtect|dataset))
}

modList <- namedList(null_model,knows_model,avoid_model,
                     base_model,interaction_model)

library(bbmle)
AICtab(modList)
save("modList",file="modList.rda")

library(ggplot2); theme_set(theme_bw())
## a1 <- augment(base_model,resid_type="pearson")  ## slow ...
## Error in sparseHessianFun(env, skipFixedEffects = skipFixedEffects) : 
##   Memory allocation fail in function 'MakeADHessObject2'
base_model <- modList$base_model
z <- getME(base_model,"Z")
x <- getME(base_model,"X")
rr <- ranef(base_model)
rr0 <- unlist(rr$cond)
## lightweight prediction ...
##  full prediction VERY slow
eta <- c(matrix(x %*% fixef(base_model)$cond  + z %*%  rr0))
mu <- plogis(eta)
y <- as.numeric(model.frame(base_model)$knowsCondomProtect)-1
plot(mu,(mu-y)/(mu*(1-mu)),pch=".",ylim=c(-20,10))

library(dotwhisker)
library(plyr)
library(broom)
bb <- ldply(modList,tidy,effects="fixed",.id="model")
## TO DO: plot obs proportions by predictors (cut if necessary),
##  with predictions (look for interactions?)

(d1 <- drop1(base_model, test="Chisq", trace=2))

###################### Base Model ###############################
summary(base_model)

############ Knowledge x PWA Interaction ######################
summary(interaction_model)

### Overall effect without interaction###
anova(base_model, null_model)

### Overall effect of interaction###
anova(base_model, interaction_model)

### Effect of "avoid" in base model ###
# Compare interaction model by dropping two "avoid" terms
anova(knows_model, base_model)

### Effect of "knows" in base model ###
# As above
anova(avoid_model, base_model)

save(list=c("d1",ls(pattern="_model")),file="models.rda")

# rdsave(base_model, ModAns)

