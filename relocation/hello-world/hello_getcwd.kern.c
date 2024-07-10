#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

//format:
//field:unsigned short common_type;       offset:0;       size:2; signed:0;
//field:unsigned char common_flags;       offset:2;       size:1; signed:0;
//field:unsigned char common_preempt_count;       offset:3;       size:1; signed:0;
//field:int common_pid;   offset:4;       size:4; signed:1;
//
//field:int __syscall_nr; offset:8;       size:4; signed:1;
//field:char * buf;       offset:16;      size:8; signed:0;
//field:unsigned long size;       offset:24;      size:8; signed:0;

struct syscall_enter_getcwd_ctx {
    unsigned short common_type;
    unsigned char common_flags;
    unsigned char common_preempt_count;
    int common_pid;
    int __syscall_nr;
    char* buf;
    unsigned long size;
};

char LICENSE[] SEC("license") = "Dual BSD/GPL";

SEC("tp/syscalls/sys_enter_getcwd")
int bpf_prog1(struct syscall_enter_getcwd_ctx *ctx)
{
    bpf_printk("%lu\n", ctx->size);
    char buf[256];
    bpf_probe_read_user(buf, sizeof(buf), ctx->buf);
    bpf_printk("%s\n", buf);
    //int a = bpf_get_prandom_u32();
    bpf_printk("Hello World\n");
    //a = bpf_get_prandom_u32();
    //bpf_printk("Hello World %d", a);
    return 0;
}
