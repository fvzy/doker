#!/bin/sh

# Start the desired command
/bin/sh -c "cloudflared tunnel --url tcp://localhost:22 --url http://localhost:8080 --hostname trycloudflare.com & /kali.sh & x11vnc -forever -usepw -create & gotty -p 8080 -w /bin/bash"
