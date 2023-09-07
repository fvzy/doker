# This Dockerfile original by : Kali-Linux-VPS ( search on github )
# Modifed by : Ditzzy ( Just adding some command to support the vps )
# So it can run on any cloud with docker & gotty so that the normal website is detected
# Please don't change anything other than the NGROK & Password contents to avoid errors






# Use kalilinux/kali-rolling as the base image
FROM kalilinux/kali-rolling

# Update packages and install locales
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && apt install -y curl

# Set locale to en_US.utf8
ENV LANG en_US.utf8

# Define NGROK & SSH password
ARG NGROK_TOKEN="2DtZEdhpCglWP39cSXxPntjBU9E_5ktNAyAotNTerbji8nbfH"
ARG Password="Ditzzy"

# Install ssh, wget, and unzip
RUN apt install ssh wget unzip -y > /dev/null 2>&1

# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip

# Add Package gotty to be able to run the web interface so that the deploy is successful
RUN curl -sSLo gotty https://raw.githubusercontent.com/afnan007a/Replit-Vm/main/gotty
RUN chmod +x gotty && mv gotty /usr/bin/

# Create shell script
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/kali.sh
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/kali.sh

# Create directory for SSH daemon's runtime files
RUN mkdir /run/sshd
RUN echo '/usr/sbin/sshd -D' >>/kali.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config # Allow root login via SSH
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config  # Allow password authentication
RUN echo root:${Password}|chpasswd # Set root password
RUN service ssh start
RUN chmod 755 /kali.sh

# Expose ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Start the shell script and gotty on container startup using a shell
CMD /bin/sh -c "/kali.sh & gotty -p 8080 -w /bin/bash"
