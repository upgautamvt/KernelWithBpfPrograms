#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>
#include <fcntl.h>

/*
 * Attempt at attaching our program.
 * This is not the right way to get a fd to a tracepoint.
 */
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

    int bpf_fd = syscall(__NR_bpf, BPF_PROG_LOAD_VERIFIED, &load, 20);

    int target_fd = open("/sys/kernel/debug/tracing/events/sys_enter_getcwd/", O_APPEND);

   // union bpf_attr link;
   // link.prog_fd = bpf_fd;
   // link.target_fd = target_fd; 

    LIBBPF_OPTS(bpf_link_create_opts, opts);
    opts.tracing.cookie = 0x1000000000000000L;
    int link_fd = bpf_link_create(bpf_fd, target_fd, BPF_TRACE_FENTRY, &opts);

    printf("link fd is %d\n", link_fd);
    while (1) {
        continue;
    }
           
}
