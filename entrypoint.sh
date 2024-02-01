#!/bin/sh
set -xe
# Start the desired command
gotty -p 8080 -w /bin/bash &
cloudflared tunnel --url http://localhost:8080 --hostname trycloudflare.com & 
/bin/sh /kali.sh &

