#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <linux/bpf.h>

/*
 * Gets the oldest loaded bpf prog on the system.
 */
int main()
{
    int err, id;
    union bpf_attr attr;
    printf("Hello World!\n");
    attr.start_id = 0;
    err = syscall(__NR_bpf, BPF_PROG_GET_NEXT_ID, &attr, 12); 
    if (err < 0) {
        printf("Failed on BPF_PROG_GET_NEXT_ID\n");
        return -1;
    }
    
    union bpf_attr p;
    p.prog_id = attr.next_id;
    err = syscall(__NR_bpf, BPF_PROG_GET_FD_BY_ID, &p, 12);

    printf("FD is %d\n", err);
    if (err < 0) {
        printf("Failed on BPF_PROG_GET_FD_BY_ID\n");
        return -1;
    }

    union bpf_attr prog = {};

    struct bpf_prog_info in = {};
    prog.info.bpf_fd = err;
    prog.info.info_len = sizeof(in);
    prog.info.info = &in;

    err = syscall(__NR_bpf, BPF_OBJ_GET_INFO_BY_FD, &prog, 16);
    printf("err: %d\n", err);
    
    printf("Name: %s\nJited prog length: %u\nXlated prog instructions: %p\n", in.name, in.jited_prog_len, (void*)(unsigned long)in.xlated_prog_insns);


                
}
