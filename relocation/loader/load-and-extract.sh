#!/usr/bin/bash

IN=$1
NAME=$2
OUT=$3

./load-and-extract $NAME $IN $OUT
./elf-combine.sh $OUT $IN $OUT.res.o

