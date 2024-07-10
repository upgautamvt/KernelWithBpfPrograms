#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>

/*
 * Sample program that shows getting the extract length of a prog
 */
int main() 
{
    int err;
    struct bpf_object* obj = bpf_object__open("kern.o");
    __u64 length;
    bpf_object__set_extract_len(obj, &length);
    err = bpf_object__load(obj);
    if (err < 0) {
        printf("Oops\n");
        return err;
    }
    printf("Program length is %llu\n", length);
//    syscall(__NR_bpf, BPF_PROG_EXTRACT, &extract_attr, 16);
}
