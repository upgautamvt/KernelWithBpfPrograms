#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>

/*
 * Takes a pre-verified bytecode and loads it and pins it
 * to the path "/sys/fs/bpf/pin"
 */
int main(int argc, char* *argv) 
{
    /* Loading the pre-verified prog */
    if (argc != 2) 
        return -1;

    char *file = argv[1];
    int err;

    FILE *fp = fopen(file, "r");
    fseek(fp, 0, SEEK_END);
    int size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    __u8 data[size+1];
    fread(data, 1, size+1, fp);

    union bpf_attr load;
    load.blob_len = size;
    load.blob = (__aligned_u64)data;
    load.blob_prog_type = BPF_PROG_TYPE_TRACEPOINT;

    int bpf_fd = syscall(__NR_bpf, BPF_PROG_LOAD_VERIFIED, &load, 20);

    union bpf_attr pin;
    char *path = "/sys/fs/bpf/pin";
    pin.pathname = (__aligned_u64)path;
    pin.bpf_fd = bpf_fd;
    pin.file_flags = 0;
    
    if (syscall(__NR_bpf, BPF_OBJ_PIN, &pin, 16) != 0)
        printf("Pin Failed\n");


           
}
