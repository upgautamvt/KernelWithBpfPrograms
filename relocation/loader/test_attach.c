#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/perf_event.h>
#include <linux/hw_breakpoint.h>

/*
 * Loads a pre-verified and jited program and then attaches
 * it to the enter of the getcwd syscall.
 */
int main(int argc, char **argv) 
{
    int err;
    int bpf_fd;

    if (argc == 2) {
        bpf_fd = bpf_obj_get(argv[1]);
    }
    else {
        FILE *fp = fopen("output", "r");
        fseek(fp, 0, SEEK_END);
        int size = ftell(fp);
        fseek(fp, 0, SEEK_SET);

        __u8 data[size+1];
        fread(data, 1, size+1, fp);

        union bpf_attr load;
        load.blob_len = size;
        load.blob = (__aligned_u64)data;
        load.blob_prog_type = BPF_PROG_TYPE_TRACEPOINT;

        bpf_fd = syscall(__NR_bpf, BPF_PROG_LOAD_VERIFIED, &load, 20);
    }

    enum bpf_attach_type at = BPF_TRACE_FENTRY;

    // Now we need an fd for getcwd syscall
    struct perf_event_attr perf;
    FILE *f = fopen("/sys/kernel/debug/tracing/events/syscalls/sys_enter_getcwd/id", "r");
    __u64 id;
    int a = fscanf(f, "%u", &id);
    fclose(f);

    memset(&perf, 0, sizeof(struct perf_event_attr));
    perf.type = PERF_TYPE_TRACEPOINT;
    perf.size = sizeof(struct perf_event_attr);
    perf.config = id;
    int pfd = syscall(__NR_perf_event_open, &perf, -1, 0, -1, PERF_FLAG_FD_CLOEXEC);

    printf("bpf_fd is %d pfd is %d\n", bpf_fd, pfd);

    //ioctl(pfd, PERF_EVENT_IOC_SET_BPF, prog_fd);
   
    union bpf_attr link;
    memset(&link, 0, sizeof(union bpf_attr));
    link.link_create.prog_fd = bpf_fd;
    link.link_create.target_fd = pfd;
    link.link_create.attach_type = BPF_PERF_EVENT;
    link.link_create.flags = 0;
//    link.link_create.tracing.target_btf_id = 0;
//    link.link_create.tracing.cookie = 0;

    int link_fd = syscall(__NR_bpf, BPF_LINK_CREATE, &link, sizeof(union bpf_attr));
    printf("link is %d\n", link_fd);

    


    //int target_fd = open("/sys/kernel/debug/tracing/events/sys_enter_getcwd/", O_APPEND);

   //// union bpf_attr link;
   //// link.prog_fd = bpf_fd;
   //// link.target_fd = target_fd; 

    //LIBBPF_OPTS(bpf_link_create_opts, opts);
    //opts.tracing.cookie = 0x1000000000000000L;
    //int link_fd = bpf_link_create(bpf_fd, target_fd, BPF_TRACE_FENTRY, &opts);

    //printf("link fd is %d\n", link_fd);
    while (1) {
        continue;
    }
           
}
