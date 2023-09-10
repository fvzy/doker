#!/bin/sh

# Start the desired command
/bin/sh -c "cloudflared tunnel --url  --url tcp://localhost:5901 --hostname trycloudflare.com & /kali.sh & x11vnc -forever -usepw -create & gotty -p 8080 -w /bin/bash"
