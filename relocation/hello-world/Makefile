all: load.c
	gcc -g -L`realpath ../../linux/tools/lib/bpf/` -I`realpath ../../linux/tools/lib/` -I`realpath ../../linux/usr/include/` load.c -lbpf -o load

set: bpf_setup.c bpf_setup.h
	gcc -g -L`realpath ../../linux/tools/lib/bpf/` -I`realpath ../../linux/tools/lib/` -I`realpath ../../linux/usr/include/` bpf_setup.c -lbpf -o bpf_setup 
