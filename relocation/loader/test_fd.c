#include <stdio.h>
#include <fcntl.h>

int main()
{
//    FILE *fp = fopen("/sys/kernel/debug/tracing/events/syscalls/sys_enter_getcwd/filter", "r");

    int fd = open("/sys/kernel/debug/tracing/events/syscalls/sys_enter_getcwd/filter", O_APPEND);

    printf("File descriptor for our tracepoint is %d\n", fd);
    return 0; 
}
