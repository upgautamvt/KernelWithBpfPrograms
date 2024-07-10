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
    union bpf_attr attr;
    u8 *data = calloc(sizeof(u8), 50);
    data[0] = 0x1;
    data[1] = 0xa;
    data[2] = 0x0;
    data[3] = 0x0;
    data[4] = 0x0;
    data[5] = 0x0;
    data[6] = 0x0;
    data[7] = 0x0;
    for (int i = 8; i < 50; i++) {
       data[i] = i; 
    }
    printf("First value after the offset table is %u\n", data[8]);

    attr.blob_prog_type = BPF_PROG_TYPE_TRACING;

    attr.blob = (__aligned_u64)data;
    attr.blob_len = 50;
    syscall(__NR_bpf, BPF_PROG_LOAD_VERIFIED, &attr, 20);
}
