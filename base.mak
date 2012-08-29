# Prevent multiple includes.
ifneq ($(BASE_INCLUDED),1)
BASE_INCLUDED := 1

# Define root directory
SRC := $(shell cd $(SRC); pwd)

# Fancy colorful output
ifndef BUILD_COLOUR
ifdef TERM
BUILD_COLOUR := $(shell [ `tput colors` -gt 2 ] && echo 1)
endif
endif
export BUILD_COLOUR V

#detect cpus
CPUS ?= $(shell ./detect_cpus.sh)
SUBMAKEFLAGS := -j$(CPUS)

# Be verbose while building only if V is set to 1 in the environment.
ifneq ($(V),1)
  Q := @
  QOUTPUT := >> /dev/null 2>&1
  MAKEFLAGS += --no-print-directory
endif

############################
# General utilities	       #
############################
RM			:= rm
MKDIR		:= mkdir
CP			:= cp

#####################
# Utility functions #
#####################

# Print a message for a command, e.g. "-> CC      foo.c"
# @param 1	Command name.
# @param 2	Extra message (e.g. file name).
ifneq ($(V),1)
  ifneq ($(BUILD_COLOUR),1)
    define cmd_msg
    @printf "[%-8s] %-$$(($(MAKELEVEL)*2))s$(2)\n" $(1) ""
    endef
  else
    define cmd_msg
    @printf "\033[1;37m[\033[1;34m%-8s\033[1;37m] \033[0;1m%-$$(($(MAKELEVEL)*2))s$(2)\033[0m\n" $(1) ""
    endef
  endif
endif

# Create the directory that the target will go in if non-existant.
define target_mkdir
@$(MKDIR) -p $(dir $(@))
endef

############################
# Core build configuration #
############################

# Define toolchain target
TOOLCHAIN_TARGET    := arm-none-eabi

# Toolchain configuration
TOOLCHAIN_SRCDIR    := $(SRC)/source
TOOLCHAIN_PATCHDIR  := $(SRC)/patches
TOOLCHAIN_BUILDDIR  := $(SRC)/build-tmp

#Install location
TOOLCHAIN_ROOTDIR   ?= $(SRC)/$(TOOLCHAIN_TARGET)

endif
