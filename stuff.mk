msrepo = https://github.com/dushoff
gitroot = ./
export ms = $(gitroot)/makestuff
Drop = ~/Dropbox/mac-theobio/Awareness_TMB

-include local.mk
-include $(gitroot)/local.mk
export ms = $(gitroot)/makestuff
-include $(ms)/os.mk

Makefile: $(ms) drop

drop:
	/bin/ln -s $(Drop) $@

$(ms):
	cd $(dir $(ms)) && git clone $(msrepo)/$(notdir $(ms)).git
