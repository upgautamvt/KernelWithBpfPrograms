//
// Created by upgautamvt on 7/10/24.
//
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/udp.h>
#include <linux/in.h>

SEC("xdp")
int xdp_prog(struct xdp_md *ctx) {
    //bpf_printk("xdp prog started\n");
    void *data_end = (void *)(long)ctx->data_end;
    void *data = (void *)(long)ctx->data;
    struct ethhdr *eth = data;

    // Check that the Ethernet header is within bounds
    if ((void *)(eth + 1) > data_end)
        return XDP_DROP;

    // Check if the packet is an IP packet
    if (eth->h_proto != __constant_htons(ETH_P_IP))
        return XDP_PASS;

    struct iphdr *ip = data + sizeof(struct ethhdr);
    if ((void *)(ip + 1) > data_end)
        return XDP_DROP;

    // Check if the packet is a TCP packet
    if (ip->protocol == IPPROTO_TCP) {
        struct tcphdr *tcp = (void *)ip + sizeof(struct iphdr);
        if ((void *)(tcp + 1) > data_end)
            return XDP_DROP;

        // Check if the destination port is 80 (HTTP) or 22 (SSH)
        if (tcp->dest == __constant_htons(80) || tcp->dest == __constant_htons(22)) {
            //bpf_printk("TCP traffic destined for port 80 or port 22\n");
            // Implement any further filtering or actions here
            // For now, we'll just pass the packet to the Nginx server
            return XDP_PASS;
        }
    }

    // Drop all other packets
    return XDP_DROP;
}

char _license[] SEC("license") = "GPL";