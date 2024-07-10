#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

char LICENSE[] SEC("license") = "Dual BSD/GPL";

struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __type(key, __u32);
    __type(value, __u32);
    __uint(max_entries, 1);
} my_map SEC(".maps");

SEC("tp/syscalls/entergetcwd")
int bpf_hello_map(void * ctx)
{
    int index = 0;
    __u32 new_val = bpf_get_prandom_u32();
    bpf_map_update_elem(&my_map, &index, (void *)&new_val, 0);
    
    void * val = bpf_map_lookup_elem(&my_map, &index);
    if (val == NULL) {
        return -1;
    }
    __u32 result = *((__u32 *)val);
    //bpf_printk("The random number is %u\n", result);
    return result;
}
