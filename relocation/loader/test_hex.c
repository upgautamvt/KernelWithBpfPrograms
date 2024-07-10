#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>

int main() 
{
    int err;
    FILE *fp = fopen("output", "r");
    fseek(fp, 0, SEEK_END);
    int size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    __u8 data[size+1];
    fread(data, 1, size+1, fp);

    union bpf_attr load;
    load.blob_len = size;
    load.blob = (__aligned_u64)data;
    load.blob_prog_type = BPF_PROG_TYPE_TRACING;

    syscall(__NR_bpf, BPF_PROG_LOAD_VERIFIED, &load, 20);
}
