USER_SRC := $(wildcard *.user.c)
USER := $(USER_SRC:.c=)
BPF-CLANG := clang
BPF_CLANG_CFLAGS := -target bpf -g -Wall -O2 -c
USER-CFLAGS := -I../../linux/usr/include -I../../linux/tools/lib/ -L../../linux/tools/lib/bpf/

all: $(USER)

$(USER) : % : %.c
	gcc $(USER-CFLAGS) $< -lbpf -o $@

.PHONY : clean


clean :
	rm $(USER)