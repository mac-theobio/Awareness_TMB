# Awareness_TMB
### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: drop/predictions.Rout 

##################################################################

# make files

Sources = Makefile .gitignore README.md stuff.mk LICENSE.md
include stuff.mk
# include $(ms)/perl.def

##################################################################

## Content

Sources += $(wildcard *.R)

## Intentionally broken chain; fix when you can
## Also, this weird linking gives circular warnings

drop/mergedData2.Rout: drop/mergedData2.RData ;
drop/models.Rout: drop/models.RData ;

drop/models2.Rout: drop/mergedData2.Rout models.R
	$(run-R)

drop/predictions.Rout: drop/mergedData2.RData drop/models.Rout varpred.Rout predictions.R
	$(run-R)

drop/predictions_nice.Rout: drop/predictions.Rout prednames.R
	$(run-R)

######################################################################

### Makestuff

## Change this name to download a new version of the makestuff directory
# Makefile: start.makestuff

-include $(ms)/git.mk
-include $(ms)/visual.mk

-include $(ms)/wrapR.mk
# -include $(ms)/oldlatex.mk
