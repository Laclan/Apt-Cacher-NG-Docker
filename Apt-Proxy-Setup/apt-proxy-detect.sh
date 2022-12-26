#!/bin/bash
# Apt Cacher NG
IP=10.27.30.200
PORT=3142
if nc -w1 -z $IP $PORT; then
    echo -n "http://${IP}:${PORT}"
else
    echo -n "DIRECT"
fi