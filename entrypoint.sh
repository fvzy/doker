#!/bin/sh

# Start the desired command
/bin/sh -c "cloudflared tunnel --url http://localhost:8080 --hostname trycloudflare.com & /kali.sh & gotty -p 8080 -w /bin/bash"
