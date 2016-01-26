
	names(isoList$educLevel)[[1]] <- "Education"
	levels(isoList$educLevel[[1]]) <-
		c("None", "Primary", "Secondary", "Higher")

	names(isoList$MrtStat)[[1]] <- "Ever Married"
	levels(isoList$MrtStat[[1]]) <-
		c("Never", "Currently", "Formerly")

	names(isoList$religion)[[1]] <- "Religion"
	levels(isoList$religion[[1]]) <-
		c("Catholic", "Christian", "Muslim", "Other")

	names(isoList$gender)[[1]] <- "Gender"
	levels(isoList$gender[[1]]) <-
		c("Female", "Male")

	names(isoList$urbanRural)[[1]] <- "Residence"
	levels(isoList$urbanRural[[1]]) <-
		c("Urban", "Rural")


	names(isoList$whoLastSex)[[1]] <- "Last Sex Partner"
	levels(isoList$whoLastSex[[1]]) <-
		c("Live-in", "Regular", "Casual", "CSW")

	names(isoList$wealthRaw)[[1]] <- "Wealth"
	
	names(isoList$age)[[1]] <- "Age"


