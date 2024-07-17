## Project setup directly in host
Clone this repo and its submodules

```c
https://github.com/rosalab/kernelwithbpfprograms-kernel
cd kernelwithbpfprograms-kernel
git submodule update --init --recursive --progress
```

### Compile Linux

```c
cd linux
cp ../q-script/.config .config
make oldconfig
make -j`nproc`
cd -
```

### Install libbpf and bpftool

```c
cd linux/tools/lib/bpf
make -j`nproc`
cd -
```

## Project setup in docker (recommended, you can skip Compile Linux and Install libbpf.. part)
We run QEMU inside a docker container. 

we should just use `sudo make vmlinux`, which build docker because we eventually use QEMU inside docker anway! You also need to install bpftool and libbpf. In docker you can do using `sudo make bpftool` and `sudo make libbpf`.

This is it.

Now, you can do

```c
cd -
sudo make qemu-run // and from another shell, sudo docker qemu-ssh (if needed)
cd -
```

# To remote gdb to QEMU (in host machine)
We have added docker to qemu port mapping
```c
DOCKER_PORT ?= "11234"
-p 127.0.0.1:${DOCKER_PORT}:1234
```

From host, now, we can remote gdb to QEMU
```c
cd -
cd linux
objcopy --only-keep-debug vmlinux kernel.sym
gdb
    (gdb) file ./kernel.sym
    (gdb) target remote localhost:11234 //11234 is our DOCKER_PORT
    (gdb) hbreak trace_call_bpf //this is the function which kprobe handler and tracepoint system use to dispatch bpf programs
    (gdb) c

```

We also need to compile all the bpf programs in bpf-progs directory, and mico in benchmarks/microbenchmarks
```c
cd -
cd bpf-progs
make clean
make
cd -
cd benchmarks/microbenchmarks
gcc -I../../linux/usr/include micro.c -o micro 
```

now, go to QEMU shell
```c
cd bpf-prog //you need to be in bpr-progs because we have ./load.user program that we use to load bpf programs
./load.user bpf_program_file bpf_prog //e.g., ./load.user empty.kern.o empty
```

now, we can run `./micro` that triggers bpf program (or debug)
