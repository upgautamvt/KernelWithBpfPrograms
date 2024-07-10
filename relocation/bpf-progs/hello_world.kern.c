#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

char LISENSE[] SEC("license") = "Dual BSD/GPL";

SEC("tp/syscalls/sys_enter_getcwd")
int bpf_hello_world(void *ctx)
{
    bpf_printk("Hello World!\n");
    return 0;
}
