#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <sys/stat.h>
#include <limits.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include <linux/perf_event.h>
#include <linux/hw_breakpoint.h>

#include <libelf.h>
#include <gelf.h>

int main(int argc, char* *argv)
{

    if (argc != 2) {
        printf("Usage: ./lbpf-testing object.o\n");
        return -1;
    }

    char * path = argv[1];
    struct bpf_object * obj = bpf_object__open_verified(path);
    int bpf_fd = bpf_object__load_verified(obj);

    struct perf_event_attr perf;
    FILE *f = fopen("/sys/kernel/debug/tracing/events/syscalls/sys_enter_getcwd/id", "r");
    __u64 id;
    int a = fscanf(f, "%llu", &id);

    printf("ID is %llu\n", id);

    memset(&perf, 0, sizeof(struct perf_event_attr));
    perf.type = PERF_TYPE_TRACEPOINT;
    perf.size = sizeof(struct perf_event_attr);
    perf.config = id;
    int pfd = syscall(__NR_perf_event_open, &perf, -1, 0, -1, 0);

//    bpf_prog_attach(bpf_fd, pfd, BPF_TRACE_RAW_TP, 0);

    bpf_link_create(bpf_fd, pfd, BPF_PERF_EVENT, NULL);

    //union bpf_attr link;
    //memset(&link, 0, sizeof(union bpf_attr));
    //link.link_create.prog_fd = bpf_fd;
    //link.link_create.target_fd = pfd;
    //link.link_create.attach_type = BPF_PERF_EVENT;
    //link.link_create.flags = 0;

    //int link_fd = syscall(__NR_bpf, BPF_LINK_CREATE, &link, sizeof(union bpf_attr));

//    ioctl(pfd, PERF_EVENT_IOC_ENABLE, 0);
//    ioctl(pfd, PERF_EVENT_IOC_SET_BPF, bpf_fd);

    for (;;) {
        continue;
    }
}
