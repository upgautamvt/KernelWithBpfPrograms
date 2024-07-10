#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <linux/bpf.h>

int main() {
    int ret = syscall(__NR_bpf, BPF_PROCESS_ENABLE, NULL, 0);
    char buf[256];
    for (int i = 0; i < 100; i++) {
        getcwd(buf, 256);
        printf("Enabled: %s\n", buf);
    }

    return 0;
}
