all: load.c
	gcc -g -L/home/milo/inner_unikernels/linux/tools/lib/bpf/ -I/home/milo/inner_unikernels/linux/tools/lib/ -I/home/milo/inner_unikernels/linux/usr/include/ load.c -lbpf -o load
	
verify:
	gcc -g -L/home/milo/decoupling/linux/tools/lib/bpf/ -I/home/milo/decoupling/linux/tools/lib/ -I/home/milo/decoupling/linux/usr/include/ verify.c -lbpf -o verify

map:
	gcc -g -L/home/milo/decoupling/linux/tools/lib/bpf/ -I/home/milo/decoupling/linux/tools/lib/ -I/home/milo/decoupling/linux/usr/include/ map_name_test.c -lbpf -o map_name_test 

