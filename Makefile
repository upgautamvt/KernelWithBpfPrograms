BASE_PROJ ?= $(shell pwd)
LINUX ?= ${BASE_PROJ}/linux
SSH_PORT ?= "52222"
DOCKER_PORT ?= "11234"
DOCKER := kernelwithbpfprograms
.ALWAYS:

all: vmlinux fs samples

docker: .ALWAYS
	make -C docker/docker-linux-builder docker

qemu-run: 
	docker run --privileged --rm \
	--device=/dev/kvm:/dev/kvm --device=/dev/net/tun:/dev/net/tun \
	-v ${BASE_PROJ}:/kernelwithbpfprograms-kernel -v ${LINUX}:/linux \
	-w /linux \
	-e LD_LIBRARY_PATH=/linux/tools/lib/bpf:${LD_LIBRARY_PATH} \
	-p 127.0.0.1:${SSH_PORT}:52222 \
	-p 127.0.0.1:${DOCKER_PORT}:1234 \
	-it ${DOCKER}:latest \
	 /kernelwithbpfprograms-kernel/q-script/yifei-q -s

# connect running qemu by ssh

qemu-ssh:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -t root@127.0.0.1 -p 52222

bpftool: 
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/bpf/bpftool ${DOCKER} make -j`nproc` bpftool 

bpftool-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/bpf/bpftool ${DOCKER} make -j`nproc` clean 

libbpf: 
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/lib/bpf/ ${DOCKER} make -j`nproc`  

dec-libbpf: 
	docker run --rm -v ${DECLINUX}:/linux -w /linux/tools/lib/bpf/ ${DOCKER} make -j`nproc`  

libbpf-clean: 
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/lib/bpf/ ${DOCKER} make -j`nproc` clean

vmlinux: 
	docker run --rm -v ${LINUX}:/linux -w /linux ${DOCKER}  make -j`nproc` bzImage

vmlinux-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux ${DOCKER}  make -j`nproc` bzImage clean

headers:
	docker run --rm -v ${LINUX}:/linux -w /linux ${DOCKER}  make headers_install 

linux-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux ${DOCKER} make distclean

# Targets for C BPF
bpf-samples:
	docker run --rm -v ${LINUX}:/linux -w /linux/samples/bpf ${DOCKER} make -j`nproc`

bpf-samples-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux/samples/bpf ${DOCKER} make clean

# Target to enter docker container
enter-docker:
	docker run --privileged --rm \
	--device=/dev/kvm:/dev/kvm --device=/dev/net/tun:/dev/net/tun \
	-v ${BASE_PROJ}:/inner_unikernels -v ${LINUX}:/linux \
	-w /linux \
	-p 127.0.0.1:${SSH_PORT}:52222 \
	-it ${DOCKER}:latest /bin/bash	

# Target to run docker in the background for ssh
docker-dev:
	docker run --privileged --rm \
	--device=/dev/kvm:/dev/kvm --device=/dev/net/tun:/dev/net/tun \
	-v ${BASE_PROJ}:/inner_unikernels -v ${LINUX}:/linux \
	-w /linux \
	-p 127.0.0.1:${SSH_PORT}:52222 \
	-d -t ${DOCKER}:latest	


#	docker run --rm -v ${BASE_PROJ}:/inner_unikernels -w /inner_unikernels -it ${DOCKER} /bin/bash

# Might not be needed anymore
iu: 
	docker run --network=host --rm -v ${LINUX}:/linux -v ${BASE_PROJ}:/inner_unikernels -w /inner_unikernels/libiu ${DOCKER} make -j32 LLVM=1

iu-clean: 
	docker run --rm -v ${LINUX}:/linux -v ${BASE_PROJ}:/inner_unikernels -w /inner_unikernels/libiu ${DOCKER} make clean

iu-examples: 
	docker run --network=host --rm -v ${LINUX}:/linux -v ${BASE_PROJ}:/inner_unikernels -w /inner_unikernels/samples/hello ${DOCKER} make -j32 LLVM=1
	docker run --network=host --rm -v ${LINUX}:/linux -v ${BASE_PROJ}:/inner_unikernels -w /inner_unikernels/samples/map_test ${DOCKER} make -j32 LLVM=1
	docker run --network=host --rm -v ${LINUX}:/linux -v ${BASE_PROJ}:/inner_unikernels -w /inner_unikernels/samples/syscall_tp ${DOCKER} make -j32 LLVM=1
	docker run --network=host --rm -v ${LINUX}:/linux -v ${BASE_PROJ}:/inner_unikernels -w /inner_unikernels/samples/trace_event ${DOCKER} make -j32 LLVM=1

DOCKERCONTEXT=\
	rootfs/Dockerfile \
	rootfs/vm-net-setup.service \
	rootfs/vm-net-setup.sh \
	rootfs/authorized_keys \
	rootfs/fstab \
	rootfs/bash_profile

rootfs/.build-base: $(DOCKERCONTEXT)
	rm -f ubuntu-ebpf.ext4
	cp ~/.ssh/id_rsa.pub rootfs/authorized_keys
	tar zc ${DOCKERCONTEXT} | docker build -f rootfs/Dockerfile -t ubuntu-ebpf -
	@echo "preparing rootfs"
	rootfs/image2rootfs.sh ubuntu-ebpf latest ext4 2>&1 > /dev/null
	touch rootfs/.build-base

fs: rootfs/.build-base

runq: rootfs/.build-base
	./qemu-run.sh bzImage ubuntu-ebpf.ext4

THISDIR=$(shell pwd)
qscript: .ALWAYS
	(cd $(HOME)/linux && $(THISDIR)/q-script/yifei-q)

hello: .ALWAYS
	make -C samples/hello/ vmcopy

map: .ALWAYS
	make -C user-framework/ vm

tracex5: .ALWAYS
	make -C samples/tracex5/

cpustat: .ALWAYS
	make -C samples/cpustat/

clean:
	rm -f ubuntu-ebpf.ext4 rootfs/.build-base

shell:
	ssh -t root@192.168.111.2 "cd /host/inner_unikernels/rootfs/guest; /bin/bash --login"

