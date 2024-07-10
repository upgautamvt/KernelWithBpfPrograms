CC=gcc
CFLAGS=-g
CFLAGS+=-L../../linux/tools/lib/bpf/ 
CFLAGS+=-I../../linux/tools/lib/ 
CFLAGS+=-I../../linux/tools/include/
CFLAGS+=-I../../linux/usr/include/
LDFLAGS=-lbpf -lelf

SRCS=$(wildcard *.c)

PROGS=$(patsubst %.c,%,$(SRCS))


all: $(PROGS)

%: %.c
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@

#load: load.c
#	gcc -g -L`realpath ../../linux/tools/lib/bpf/` -I`realpath ../../linux/tools/lib/` -I`realpath ../../linux/usr/include/` load.c -lbpf -o load

set: bpf_setup.c bpf_setup.h
	gcc -g -L`realpath ../../linux/tools/lib/bpf/` -I`realpath ../../linux/tools/lib/` -I`realpath ../../linux/usr/include/` bpf_setup.c -lbpf -o bpf_setup 

loader: loader.c
	gcc -g -L`realpath ../../linux/tools/lib/bpf/` -I`realpath ../../linux/tools/lib/` -I`realpath ../../linux/usr/include/` loader.c -lbpf -o loader

extract: extract.c
	gcc -g -L`realpath ../../linux/tools/lib/bpf/` -I`realpath ../../linux/tools/lib/` -I`realpath ../../linux/usr/include/` extract.c -lbpf -o extract
