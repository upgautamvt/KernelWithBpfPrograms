#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <linux/types.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <unistd.h>
#include <linux/perf_event.h>
#include <linux/hw_breakpoint.h>

#include <libelf.h>
#include <gelf.h>

int main(int argc, char* *argv) 
{
    int err;
    union bpf_attr attr;

    if (argc != 2) {
        printf("Usage: ./load-verified object.o\n");
    }

    char * path = argv[1];

    FILE * fp = fopen(path, "r");
    int fd = fileno(fp);


    Elf *e;
    char *k;

    // setup elf_version
    if (elf_version(EV_CURRENT) == EV_NONE) {
        printf("Error\n");
        return -1;
    }

    e = elf_begin(fd, ELF_C_READ, NULL);
    if (e == NULL) {
        printf("Error\n");
        return -1;
    }

    if (elf_kind(e) != ELF_K_ELF) {
        printf("Error\n");
        return -1;
    }
    
    size_t num_section;
    elf_getshdrnum(e, &num_section);

    num_section = num_section - 1;
    Elf_Scn * sec = elf_getscn(e, num_section);

    Elf_Data * data = elf_getdata(sec, data);

    

    // Get the size of the file
    size_t file_size = data->d_size; // size of the section
    //fseek(fp, 0L, SEEK_END);
    //file_size = ftell(fp);
    //rewind(fp);

    //__u32 reloc_len;

    __u32 reloc_len = *(__u32 *)(data->d_buf);
//    size_t res = fread(&reloc_len, sizeof(__u32), 1, fp);
    //if (res != 1) {
    //    printf("Error reading relocation length\n");
    //    return -1;
    //}

    struct bpf_relocation * relocs = calloc(reloc_len, sizeof(struct bpf_relocation));

    memcpy(relocs, data->d_buf + 4, reloc_len * sizeof(struct bpf_relocation));
    // Copies the relocations into the relocs array
    
    //res = fread(relocs, sizeof(struct bpf_relocation), reloc_len, fp);
    //if (res != reloc_len) {
    //    printf("Error reading in relocations\n");
    //    return -1;
    //}

    size_t prog_len = file_size - (sizeof(__u32) + (reloc_len * sizeof(struct bpf_relocation)));

    __u8 * prog = calloc(1, prog_len);

    // copy program into prog
    memcpy(prog, data->d_buf + 4 + (reloc_len * sizeof(struct bpf_relocation)), prog_len);

    //res = fread(prog, 1, prog_len, fp);
    
    //if (res != prog_len) {
    //    printf("Error reading in program\n");
    //    return -1;
    //}

   attr.blob_prog_type = BPF_PROG_TYPE_TRACEPOINT;
    printf("tracing %d\n", attr.blob_prog_type);
    struct bpf_relocation * reloc;
    for (int i = 0; i < reloc_len; i++) {
        reloc = relocs + i;
        printf("%u %x %s\n", reloc->type, reloc->offset, reloc->symbol);
    }            

    fclose(fp);
   attr.blob = (__aligned_u64)prog;
   attr.blob_len = prog_len;
   attr.relocations = (__aligned_u64)relocs;
   attr.relocations_length = reloc_len;

   printf("Attr has size: %ld\n", sizeof(attr));
   int bpf_fd = syscall(__NR_bpf, BPF_PROG_LOAD_VERIFIED, &attr, sizeof(attr));


    struct perf_event_attr perf;
    FILE *f = fopen("/sys/kernel/debug/tracing/events/syscalls/sys_enter_getcwd/id", "r");
    __u64 id;
    int a = fscanf(f, "%u", &id);
    fclose(f);

    memset(&perf, 0, sizeof(struct perf_event_attr));
    perf.type = PERF_TYPE_TRACEPOINT;
    perf.size = sizeof(struct perf_event_attr);
    perf.config = id;
    int pfd = syscall(__NR_perf_event_open, &perf, -1, 0, -1, PERF_FLAG_FD_CLOEXEC);

    printf("bpf_fd is %d pfd is %d\n", bpf_fd, pfd);

    //ioctl(pfd, PERF_EVENT_IOC_SET_BPF, prog_fd);
   
    union bpf_attr link;
    memset(&link, 0, sizeof(union bpf_attr));
    link.link_create.prog_fd = bpf_fd;
    link.link_create.target_fd = pfd;
    link.link_create.attach_type = BPF_PERF_EVENT;
    link.link_create.flags = 0;
//    link.link_create.tracing.target_btf_id = 0;
//    link.link_create.tracing.cookie = 0;

    int link_fd = syscall(__NR_bpf, BPF_LINK_CREATE, &link, sizeof(union bpf_attr));
    printf("link is %d\n", link_fd);

   for (;;)
       continue;
}
