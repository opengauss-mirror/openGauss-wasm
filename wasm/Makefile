# contrib/wasm/Makefile

MODULE_big = wasm_engine
OBJS= wasm_engine.o

EXTENSION = wasm_engine
DATA = wasm_engine--1.0.sql

SHLIB_LINK_INTERNAL = $(libpq)
SHLIB_LINK += -lwasmedge

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/wasm
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
override CPPFLAGS := $(filter-out -fPIE, $(CPPFLAGS)) -fPIC
endif
