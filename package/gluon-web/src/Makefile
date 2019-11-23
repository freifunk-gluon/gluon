all: compile

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -D_GNU_SOURCE -std=c99 -Wall -Wextra -fPIC -fvisibility=hidden -c -o $@ $<

clean:
	rm -f parser.so *.o

parser.so: template_parser.o template_utils.o template_lmo.o template_lualib.o
	$(CC) $(LDFLAGS) -shared -o $@ $^

gluon-po2lmo: gluon-po2lmo.o template_lmo.o

compile: parser.so

install: compile
	mkdir -p $(DESTDIR)/usr/lib/lua/gluon/web/template
	cp parser.so $(DESTDIR)/usr/lib/lua/gluon/web/template/parser.so
