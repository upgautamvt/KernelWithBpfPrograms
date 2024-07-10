#include <stdio.h>
#include <stdlib.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>


/*
 * Loads a BPF program and attaches it with libbpf
 */

__u64 ptr_to_u64(void *ptr)
{
    return (__u64) (unsigned long) ptr;
}

int main(int argc, char* argv[]) 
{
    int err;
    printf("%s\n", argv[1]);
    struct bpf_object* obj = bpf_object__open(argv[1]);
    err = bpf_object__load(obj);
    if (err < 0) {
        printf("Oops\n");
        return err;
    }
    
    __u32 id = 0;
    bpf_prog_get_next_id(id, &id);
    int fd = bpf_prog_get_fd_by_id(id);

    struct bpf_prog_info inf = {};
    size_t size = 0;
    void *a = NULL;
    __u32 len = sizeof(struct bpf_prog_info);
    err = bpf_obj_get_info_by_fd(fd, &inf, &len);

    struct bpf_program* pro = bpf_object__next_program(obj, NULL);
    if (!pro) {
        printf("Null Program\n");
        exit(1);
    }
    bpf_program__attach(pro);

    char buf[10]; while (1) {
        getcwd(buf, 10);
        sleep(1);
    }
    //printf("%s\n", inf.name);
    //printf("ptr: %llu\n", inf.jited_prog_insns);

    //for (int i = 0; i < inf.jited_prog_len; i++) {
    //    printf("%x ", *((__u8 *)inf.jited_prog_insns + i));
    //}
    //printf("\nRelocations: %lld\n", inf.relocations); 
    
    //for (int i = 0; i < inf.xlated_prog_len; i++) {
    //    printf("%x ", *((__u8 *)inf.xlated_prog_insns + i));
    //}

    //printf("Hello World!\n");
}
