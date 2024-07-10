#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <time.h>
#include <stdlib.h>

#include <bpf/bpf.h>
#include <bpf/libbpf.h>

int main()
{
    syscall(__NR_bpf, BPF_PROCESS_ENABLE, NULL, 0);
    struct bpf_object * obj = bpf_object__open("hello_kprobe.kern.o");
    
    if (bpf_object__load(obj)) {
        printf("Failed");
        return 0;
    }

    struct bpf_program * km_enter = bpf_object__find_program_by_name(obj, "km_enter");
    struct bpf_program * km_ret = bpf_object__find_program_by_name(obj, "km_ret");

    if (km_enter == NULL) {
        printf("enter failed\n");
        return 0;
    }
    if (km_ret == NULL) {
        printf("ret failed\n");
        return 0;
    }

    bpf_program__attach(km_enter);
    bpf_program__attach(km_ret);

    while (1) {
        sleep(1);
    }

    return 0;
}
