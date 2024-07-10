#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

/*
 * BPF program that gets a random number
 * then prints "Hello World"
 */
char LICENSE[] SEC("license") = "Dual BSD/GPL";

SEC("tp/syscalls/sys_enter_getcwd")
int bpf_prog1(void *ctx)
{
    int a = bpf_get_prandom_u32();
    bpf_printk("Hello World %d\n", a);
    return 0;
}
