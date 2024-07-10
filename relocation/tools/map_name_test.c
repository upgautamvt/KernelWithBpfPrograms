#include<sys/syscall.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>
#include <stdlib.h>

int main() 
{
    // Create a map
    int fd = bpf_map_create(BPF_MAP_TYPE_ARRAY,
                             "test_map_name",
                             4, 4, 1, NULL);
    //if (!fd) 
    //   exit(-1);
    
    // Pin an object by using a FD
    int ret = bpf_obj_pin(fd, "/sys/fs/bpf/map1"); 
    //if (ret)
    //    exit(-1);

    // BPF_TEST_MAP will print the name of the map at the path
    // /sys/fs/bpf/map1
    syscall(__NR_bpf, BPF_TEST_MAP, NULL, 0);

}
