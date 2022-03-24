defmacro:=-D
incdir:=-I
include $(ROOT_DIR)/config.mk

DEFINE+=$(defmacro)BAUD=$(BAUD)
DEFINE+=$(defmacro)FREQ=$(FREQ)

#compiler settings
TOOLCHAIN_PREFIX:=riscv64-unknown-elf-
CFLAGS=-Os -nostdlib -march=$(MFLAGS) -mabi=ilp32 --specs=nano.specs
LFLAGS+= -Wl,-Bstatic,-T,../template.lds,--strip-debug
LLIBS=-lgcc -lc -lnosys

MFLAGS=$(MFLAGS_BASE)$(MFLAG_M)$(MFLAG_C)

MFLAGS_BASE:=rv32i

ifeq ($(USE_MUL_DIV),1)
MFLAG_M=m
endif

ifeq ($(USE_COMPRESSED),1)
MFLAG_C=c
endif

#INCLUDE
INCLUDE+=$(incdir)$(SW_DIR) $(incdir).

#add iob-lib to include path
INCLUDE+=$(incdir)$(LIB_DIR)/software/include

#headers
HDR=$(SW_DIR)/system.h

#common sources (none so far)
#SRC=$(SW_DIR)/*.c

#peripherals' base addresses
periphs.h: periphs_tmp.h
	@is_diff=`diff -q -N $@ $<`; if [ "$$is_diff" ]; then cp $< $@; fi
	@rm periphs_tmp.h

periphs_tmp.h:
	$(foreach p, $(PERIPHERALS), $(shell echo "#define $p_BASE (1<<$P) |($p<<($P-N_SLAVES_W))" >> $@) )

gen_data:
	make -C $(SW_TEST_DIR) gen_test_data TEST_VECTOR_RSP=$(TEST_VECTOR_RSP)
	mv $(SW_TEST_DIR)/*d_in.bin .
