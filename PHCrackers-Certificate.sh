#!/bin/sh
PUBLIC_IP=`curl -s http://ifconfig.me/ip`

echo "Server Public IP ${PUBLIC_IP}"

