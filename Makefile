SRC                 := .
include $(SRC)/base.mak

all: info

LASTDEFINED_TARGET :=
include $(SRC)/binutils.mak
include $(SRC)/gcc-newlib.mak
include $(SRC)/gdb.mak
include $(SRC)/openocd.mak
include $(SRC)/stlink.mak

STARTTIME := $(shell date +%s)
all:
	$(call cmd_msg,INFO,Build completed in $$(($$(date +%s)-$(STARTTIME))) seconds)
	$(call cmd_msg,INFO,Execute a >>make clean<< to remove build tempfiles)

info:
	$(call cmd_msg,INFO,Using $(CPUS) CPUs)
	$(call cmd_msg,INFO,Installing toolchain to $(TOOLCHAIN_ROOTDIR))

clean:
	$(Q)if [ -n "$(TOOLCHAIN_BUILDDIR)" -a -d "$(TOOLCHAIN_BUILDDIR)" ]; then \
		rm -rf $(TOOLCHAIN_BUILDDIR); \
	fi

distclean: clean
	$(Q)if [ -n "$(TOOLCHAIN_SRCDIR)" -a -d "$(TOOLCHAIN_SRCDIR)" ]; then \
		rm -rf $(TOOLCHAIN_SRCDIR); \
	fi

.PHONY: info download clean distclean
.DEFAULT_GOAL = all
