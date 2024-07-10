#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>

#include <libelf.h>
#include <gelf.h>

/*
 * Loads a program then extracts it and prints out all the bytes to stdout.
 */
int main(int argc, char* *argv) 
{
    if (argc != 4) {
        printf("Usage: ./test_extract_prog prog_name input.o output.o\n");
        return -1;
    }
    char * prog_name = argv[1];
    char * input = argv[2];
    char * output = argv[3];

    int err;
    struct bpf_object* obj = bpf_object__open(input);
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
        printf("bpf prog name is %s\n", inf.name);
        if (strcmp(inf.name, prog_name) == 0) {
            break;
        }
    } while (err == 0); // if err is 0 then we are good


    union bpf_attr at;
    at.output_ptr = (__aligned_u64)calloc(1, length);
    at.output_ptr_len = length;
    at.prog_fd = fd; 

    syscall(__NR_bpf, BPF_PROG_EXTRACT, &at, 16);

    __u8 *data = (__u8*)at.output_ptr;
    
    FILE * fp = fopen(output, "w");
    fwrite(data, length, 1, fp);
    fclose(fp);
    
    for (int i = 0; i < length; i++) {
        printf("%x ", *(data + i));
    } 

    bpf_object__close(obj); 

}
