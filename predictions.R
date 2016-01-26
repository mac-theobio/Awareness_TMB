library(lme4)
library(splines)

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

ModAns <- merge(ModAns,hivprev)
 
isoNames <- c("educLevel", "MrtStat", "religion", "gender" ,"urbanRural", "whoLastSex", "age", "wealthRaw")
 
isoNames <- c("educLevel", "MrtStat", "religion", "gender" ,"urbanRural", "whoLastSex", "age", "wealthRaw")
 
isoList <- lapply(isoNames, function(n){
	varpred(base_model, n, ModAns, isolate=TRUE)
})
 
names(isoList) <- isoNames
 
#rdsave(isoList)
