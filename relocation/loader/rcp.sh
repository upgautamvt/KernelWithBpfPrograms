#!/usr/bin/bash

scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -P 52222 root@127.0.0.1:$1 $2 
