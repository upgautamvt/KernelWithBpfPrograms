#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <bpf/bpf.h>
#include <linux/types.h>

/*
 * Tries to extract a BPF program from the kernel
 */
int main(int argc, char* argv[])
{

    union bpf_attr at;
    void* a = calloc(2048, 1);
    
    printf("%s\n", argv[1]);
    at.bpf_fd = atoi(argv[1]);
    at.output_ptr = (__aligned_u64)a;
    printf("%llx\n", at.output_ptr);
    at.extract_len = 2048; 

    syscall(__NR_bpf, BPF_PROG_EXTRACT, &at, sizeof(at));
    
    printf("%x\n", *((__u8*)a));
    free(a);
    return 0;
}
