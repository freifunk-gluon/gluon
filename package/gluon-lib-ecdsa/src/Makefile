CFLAGS  += -Wall -fPIC
LDFLAGS += -llua -lm
OBJ = hexutil.o ecdsa_util.o util.c ecdsa.o
LIB = ecdsa.so

CFLAGS += $(shell pkg-config --cflags ecdsautil)
LDFLAGS += $(shell pkg-config --libs ecdsautil)

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LUA_CFLAGS) $(CFLAGS) $(FPIC) -c -o $@ $<

all: compile

compile: $(OBJ)
	$(CC) $(LDFLAGS) -fPIC -shared -o $(LIB) $(OBJ) $(LDFLAGS)

install: compile
	mkdir -p $(DESTDIR)/usr/lib/lua/gluon
	cp $(LIB) $(DESTDIR)/usr/lib/lua/gluon/$(LIB)

clean:
	rm -f *.o *.so
