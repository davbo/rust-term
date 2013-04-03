RUSTC = rustc

MAIN_SOURCE = src/term.rs
OTHER_SOURCES = src/hexes.rs src/ios.rs src/info.rs src/util.rs src/trie.rs
TESTS = bin/termios bin/termios2 bin/termios3 bin/rl bin/password bin/attrs bin/tput

all: build tests

build: tmp/built

check: build
	$(RUSTC) -L tmp --test $(MAIN_SOURCE) -o TEST
	./TEST
	@rm -f TEST

tests: $(TESTS)

bin/%: test/%.rs tmp/built
	@mkdir -p bin
	$(RUSTC) --out-dir bin -L lib $<

tmp/built: $(MAIN_SOURCE) $(OTHER_SOURCES) tmp/libtermios_wrapper.a tmp/libcurses_helper.a tmp/libio_helper.a
	@mkdir -p lib
	$(RUSTC) --out-dir lib -L tmp $(MAIN_SOURCE) && touch tmp/built

clibs: tmp/libtermios_wrapper.a tmp/libcurses_helper.a tmp/libio_helper.a

tmp/libtermios_wrapper.a: tmp/termios_wrapper.o
	ar cr $@ $<

tmp/termios_wrapper.o: src/termios_wrapper.c
	@mkdir -p tmp
	cc -fPIC -c -o $@ $<

tmp/libcurses_helper.a: tmp/curses_helper.o
	ar cr $@ $<

tmp/curses_helper.o: src/curses_helper.c
	@mkdir -p tmp
	cc -fPIC -c -o $@ $<

tmp/libio_helper.a: tmp/io_helper.o
	ar cr $@ $<

tmp/io_helper.o: src/io_helper.c
	@mkdir -p tmp
	cc -fPIC -c -o $@ $<

clean:
	-@rm -rf lib/ bin/ tmp/

.PHONY: all clean build tests default
