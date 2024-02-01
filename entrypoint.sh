#!/bin/sh
sh -c '
    /bin/sh /kali.sh &
    gotty -p 8080 -w /bin/bash &
    cloudflared tunnel --url http://localhost:8080 --hostname trycloudflare.com
' &
