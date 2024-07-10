/* 
 * I have no idea what this does or what it is for.
 */

#include <stdio.h>
#include <stdlib.h>
#include <linux/types.h>
#include <bpf/bpf.h>
#include <bpf/libbpf.h>

int prep_prog_info(struct bpf_prog_info *const info, void **info_data, size_t *const info_data_sz);

__u64 ptr_to_u64(void *ptr)
{
    return (__u64) (unsigned long) ptr;
}

int main() 
{
    int err;
    struct bpf_object* obj = bpf_object__open("kern.o");
    err = bpf_object__load(obj);
    if (err < 0) {
        printf("Oops\n");
        return err;
    }
    
    __u32 id = 0;
    bpf_prog_get_next_id(id, &id);
    int fd = bpf_prog_get_fd_by_id(id);

    struct bpf_prog_info inf = {};
    size_t size = 0;
    void *a = NULL;
    __u32 len = sizeof(struct bpf_prog_info);
    err = bpf_obj_get_info_by_fd(fd, &inf, &len);
    prep_prog_info(&inf, &a, &size);
    err = bpf_obj_get_info_by_fd(fd, &inf, &len);
    printf("%s\n", inf.name);
    printf("ptr: %llu\n", inf.jited_prog_insns);

    for (int i = 0; i < inf.jited_prog_len; i++) {
        printf("%x ", *((__u8 *)inf.jited_prog_insns + i));
    }
    printf("\nRelocations: %lld\n", inf.relocations); 
    
    for (int i = 0; i < inf.xlated_prog_len; i++) {
        printf("%x ", *((__u8 *)inf.xlated_prog_insns + i));
    }

    printf("Hello World!\n");
}

int prep_prog_info(struct bpf_prog_info *const info,
			  void **info_data, size_t *const info_data_sz)
{
	struct bpf_prog_info holder = {};
	size_t needed = 0;
	void *ptr;

    holder.jited_prog_len = info->jited_prog_len;
	needed += info->jited_prog_len;

    holder.xlated_prog_len = info->xlated_prog_len;
	needed += info->xlated_prog_len;

	holder.nr_jited_ksyms = info->nr_jited_ksyms;
	needed += info->nr_jited_ksyms * sizeof(__u64);

	holder.nr_jited_func_lens = info->nr_jited_func_lens;
	needed += info->nr_jited_func_lens * sizeof(__u32);

	holder.nr_func_info = info->nr_func_info;
	holder.func_info_rec_size = info->func_info_rec_size;
	needed += info->nr_func_info * info->func_info_rec_size;

	holder.nr_line_info = info->nr_line_info;
	holder.line_info_rec_size = info->line_info_rec_size;
	needed += info->nr_line_info * info->line_info_rec_size;

	holder.nr_jited_line_info = info->nr_jited_line_info;
	holder.jited_line_info_rec_size = info->jited_line_info_rec_size;
	needed += info->nr_jited_line_info * info->jited_line_info_rec_size;

	if (needed > *info_data_sz) {
		ptr = realloc(*info_data, needed);
		if (!ptr)
			return -1;

		*info_data = ptr;
		*info_data_sz = needed;
	}
	ptr = *info_data;

	holder.jited_prog_insns = ptr_to_u64(ptr);
	ptr += holder.jited_prog_len;
	
    holder.xlated_prog_insns = ptr_to_u64(ptr);
	ptr += holder.xlated_prog_len;

	holder.jited_ksyms = ptr_to_u64(ptr);
	ptr += holder.nr_jited_ksyms * sizeof(__u64);

	holder.jited_func_lens = ptr_to_u64(ptr);
	ptr += holder.nr_jited_func_lens * sizeof(__u32);

	holder.func_info = ptr_to_u64(ptr);
	ptr += holder.nr_func_info * holder.func_info_rec_size;

	holder.line_info = ptr_to_u64(ptr);
	ptr += holder.nr_line_info * holder.line_info_rec_size;

	holder.jited_line_info = ptr_to_u64(ptr);
	ptr += holder.nr_jited_line_info * holder.jited_line_info_rec_size;

    holder.relocations = ptr_to_u64(ptr);
    ptr += holder.relocations;

	*info = holder;
	return 0;
}
