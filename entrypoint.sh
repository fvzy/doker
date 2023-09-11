#!/bin/sh

# Start the desired command
/bin/sh -c "./ngrok tcp 22 & ./ngrok tcp 5900 & cloudflared tunnel --url tcp://localhost:8080 --hostname trycloudflare.com & /kali.sh & x11vnc -forever -usepw -create & gotty -p 8080 -w /bin/bash"
