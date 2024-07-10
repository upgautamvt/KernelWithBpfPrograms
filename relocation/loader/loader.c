#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <linux/types.h>
#include <bpf/bpf.h>
#include <bpf/libbpf.h>

int main()
{
    union bpf_attr attr;
    int verify, extract;
    verify = syscall(__NR_bpf, BPF_PROG_VERIFY, &attr, 12); 
    extract = syscall(__NR_bpf, BPF_PROG_EXTRACT, &attr, 12);
    
    printf("Return value from verify is %d\nReturn value from extract is %d\n", verify, extract);
    return 0;
}

