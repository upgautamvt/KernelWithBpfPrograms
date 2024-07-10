#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <linux/bpf.h>

int main() {
    int ret = syscall(__NR_bpf, BPF_PROCESS_ENABLE, NULL, 0);
    char buf[256];
    getcwd(buf, 256);
    printf("Enabled: %s\n", buf);

    ret = syscall(__NR_bpf, BPF_PROCESS_DISABLE, NULL, 0);
    getcwd(buf, 256);
    printf("Disabled: %s\n", buf);
    return 0;
}
