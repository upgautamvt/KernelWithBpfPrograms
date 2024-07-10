#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>

/*
 * Loads a bpf program and then extracts the verified and jited bytecode 
 * to the given path
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

    __u32 id = 0;
    int fd;
    __u32 len = sizeof(struct bpf_prog_info);
    struct bpf_prog_info inf;
    do {
        bpf_prog_get_next_id(id, &id);
        fd = bpf_prog_get_fd_by_id(id);
        err = bpf_obj_get_info_by_fd(fd, &inf, &len);
        if (strcmp(inf.name, "bpf_prog1") == 0) {
            break;
        }
    } while (err != 0);


    union bpf_attr at;
    at.output_ptr = (__aligned_u64)calloc(1, length);
    at.output_ptr_len = length;
    at.prog_fd = fd; 

    syscall(__NR_bpf, BPF_PROG_EXTRACT, &at, 16);

    __u8 *data = (__u8*)at.output_ptr;
    
    for (int i = 0; i < length; i++) {
        printf("%x ", *(data + i));
    } 

    FILE *fp = fopen("output", "w");
    fwrite(data, 1, length, fp);
    fclose(fp);

//    union bpf_attr load;
//    load.blob_len = length;
//    load.blob = at.output_ptr;
//    load.blob_prog_type = BPF_PROG_TYPE_TRACING;
//
//    syscall(__NR_bpf, BPF_PROG_LOAD_VERIFIED, &load, 20);

           
}
