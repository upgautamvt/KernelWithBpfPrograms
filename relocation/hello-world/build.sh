#!/usr/bin/env bash
clang -g -I`realpath ../../linux/tools/lib` -I`realpath ../../linux/usr/include` -I`realpath ../../linux/include` -I`realpath ../../linux/arch/x86/include` -target bpf -Wall -O2 -c $1.c -o $1.o
