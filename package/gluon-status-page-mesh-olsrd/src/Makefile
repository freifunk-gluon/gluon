all: neighbours-olsrd

CFLAGS += -Wall -D_GNU_SOURCE

ifeq ($(origin PKG_CONFIG), undefined)
  PKG_CONFIG = pkg-config
  ifeq ($(shell which $(PKG_CONFIG) 2>/dev/null),)
    $(error $(PKG_CONFIG) not found)
  endif
endif

CFLAGS_JSONC = $(shell $(PKG_CONFIG) --cflags json-c)
LDFLAGS_JSONC = $(shell $(PKG_CONFIG) --libs json-c)

CFLAGS_OLSR += $(shell $(PKG_CONFIG) --cflags libolsrdhelper)
LDFLAGS_OLSR += $(shell $(PKG_CONFIG) --libs libolsrdhelper)

neighbours-olsrd: neighbours-olsrd.c
	$(CC) $(CFLAGS) $(CFLAGS_JSONC) $(CFLAGS_OLSR) $(LDFLAGS) $(LDFLAGS_JSONC) $(LDFLAGS_OLSR) -o $@ $^ $(LDLIBS)
