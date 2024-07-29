SOURCES := $(wildcard *.kern.c)
FILES := $(SOURCES:.c=.o)
BPF-CLANG := clang
BPF_CLANG_CFLAGS := -target bpf -g -Wall -O2 -c
INCLUDE := -I../linux/usr/include/ -I../linux/tools/lib/

all: $(FILES)
	
$(FILES) : %.o : %.c
	$(BPF-CLANG) $(INCLUDE) $(BPF_CLANG_CFLAGS) -o $@ $<

.PHONY : clean

map-fine-clean:
	rm $(FILES)

clean :
	rm $(FILES)
