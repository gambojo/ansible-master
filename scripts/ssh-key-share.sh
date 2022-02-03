#!/bin/bash

#for ip in `cat ./no_keys.txt`; do
    #ssh-copy-id administrator@$ip
    #ping -t 4 $ip
#done

COMM="
spawn ssh administrator@10.3.72.116
set timeout 10
expect \"*(yes/no)?*\" {send \"yes\r\"}
expect \"*password:\" {send \"Qwerty3691475\r\"}
expect \"*~$\" {send \"users\r\"}
xpect eof
"
expect -c "$COMM"
#'sudo ip a | grep inet | sed "\1 \d" | awk '{print \$2}' ; users'
