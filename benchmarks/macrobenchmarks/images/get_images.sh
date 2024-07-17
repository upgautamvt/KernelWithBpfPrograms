#!/bin/bash

(type curl > /dev/null 2>&1 && curl https://people.cs.vt.edu/tansanrao/artifacts/moo-kernel-images.tar.zst -o moo-kernel-images.tar.zst) || (type wget > /dev/null 2>&1 && wget https://people.cs.vt.edu/tansanrao/artifacts/moo-kernel-images.tar.zst)

tar xaf moo-kernel-images.tar.zst
