STLINK_BRANCH     := master
STLINK_GIT        := git://github.com/texane/stlink.git
STLINK_PATCHES    := 

# Clone sources
$(TOOLCHAIN_BUILDDIR)/.stlink-clone:
	$(Q)mkdir -p $(TOOLCHAIN_BUILDDIR)
	$(call cmd_msg,GITCLONE,$(STLINK_GIT) $(STLINK_BRANCH))

	$(Q)git clone -b $(STLINK_BRANCH) $(STLINK_GIT) $(TOOLCHAIN_BUILDDIR)/stlink-$(STLINK_BRANCH)
	
	$(call cmd_msg,PATCH,$(subst $(SRC)/$(SRCSUBDIR)/,,$(STLINK_PATCHES)))
	$(Q)$(foreach patch,$(STLINK_PATCHES), \
		cd $(TOOLCHAIN_BUILDDIR)/stlink-$(STLINK_BRANCH); \
		patch -Np1 -i $(patch) $(QOUTPUT); \
	)
	$(Q)touch $(@)


# Configure
$(TOOLCHAIN_BUILDDIR)/.stlink-configure: $(TOOLCHAIN_BUILDDIR)/.stlink-clone
	$(Q)if [ -d "$(TOOLCHAIN_BUILDDIR)/stlink-build" ]; then \
		rm -rf $(TOOLCHAIN_BUILDDIR)/stlink-build; \
	fi
	$(Q)mkdir -p $(TOOLCHAIN_BUILDDIR)/stlink-build
	$(call cmd_msg,CONFIG,stlink-$(STLINK_BRANCH) ($(TOOLCHAIN_TARGET)))
	$(Q)cd $(TOOLCHAIN_BUILDDIR)/stlink-$(STLINK_BRANCH); ./autogen.sh $(QOUTPUT)
	$(Q)cd $(TOOLCHAIN_BUILDDIR)/stlink-build; \
		../stlink-$(STLINK_BRANCH)/configure \
		--prefix=$(TOOLCHAIN_ROOTDIR) \
		$(QOUTPUT)
	$(Q)touch $(@)


# Compile
$(TOOLCHAIN_BUILDDIR)/.stlink-compile: $(TOOLCHAIN_BUILDDIR)/.stlink-configure
	$(call cmd_msg,COMPILE,stlink-$(STLINK_BRANCH) ($(TOOLCHAIN_TARGET)))
	$(Q)cd $(TOOLCHAIN_BUILDDIR)/stlink-build; $(MAKE) $(SUBMAKEFLAGS) $(MAKEFLAGS) all $(QOUTPUT)
	$(Q)touch $(@)


# Install
$(TOOLCHAIN_BUILDDIR)/.stlink-install: $(TOOLCHAIN_BUILDDIR)/.stlink-compile
	$(call cmd_msg,INSTALL,stlink-$(STLINK_BRANCH) ($(TOOLCHAIN_TARGET)))
	$(Q)cd $(TOOLCHAIN_BUILDDIR)/stlink-build; $(MAKE) $(MAKEFLAGS) install $(QOUTPUT)
	$(Q)touch $(@)


# Download, build and install stlink to run on the host system.
STLINK_TARGET := $(TOOLCHAIN_BUILDDIR)/.stlink-install
all-stlink: $(STLINK_TARGET)
.PHONY: all-stlink

all: $(STLINK_TARGET)
download: $(TOOLCHAIN_BUILDDIR)/.stlink-clone
