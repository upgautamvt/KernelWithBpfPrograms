#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

/*
 * Program trying to do a test run of a loaded bpf program
 */
int main(int argc, char* *argv) 
{
    if (argc != 2) {
        printf("Need to have a path\n");
        return -1;
    }

    printf("Path is %s", argv[1]);

    int fd = bpf_obj_get(argv[1]);
    if (fd < 0) {
        printf("Couldn't get bpf prog fd\n");
        return -1;
    }

    LIBBPF_OPTS(bpf_test_run_opts, run);

    run.data_size_in = 0;
    run.data_size_out = 0;

    run.ctx_size_in = 0;
    run.ctx_size_out = 0;
    run.repeat = 0;
    run.flags = 0;

    int ret = bpf_prog_test_run_opts(fd, &run);
    printf("Prog ret val was %d\n", run.retval);
    printf("%s\n", strerror(-1 * ret));
    return ret;
}
