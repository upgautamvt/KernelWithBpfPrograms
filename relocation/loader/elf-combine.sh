#!/usr/bin/bash
llvm-objcopy --add-section .decouple=$1 $2 $3
