BASE_PROJ ?= $(realpath $(shell pwd)/../../)
LINUX ?= ${BASE_PROJ}/linux

test11:
	$(info $(BASE_PROJ))

docker: Dockerfile
	docker build --no-cache --network=host --progress=auto -t kernelwithbpfprograms .


linux:
	docker run --rm -v ${LINUX}:/linux linux-builder make -j`nproc` bzImage 

linux-clean:
	docker run -v ${LINUX}:/linux linux-builder make clean

