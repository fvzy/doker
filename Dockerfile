# Use kalilinux/kali-rolling as the base image
FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
# Update packages and install locales
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && apt install -y curl

# Set locale to en_US.utf8
ENV LANG en_US.utf8

# Define NGROK & SSH password
ARG NGROK_TOKEN="2A0URlDUw7eukFNE1AgSndmTXpc_7rF456g8KPtn9SUUdnk5W"
ARG Password="Ditzzy"

# Install ssh, wget, and unzip
RUN apt install ssh wget unzip -y > /dev/null 2>&1

# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip

# Install ssh, wget, unzip, and Node.js
ENV NODE_VERSION=16.13.0
RUN apt install -y curl
RUN curl -o-  https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Set the working directory for your Node.js application
WORKDIR /

# Copy your package.json and package-lock.json to the container
#COPY package.json ./

# Install Node.js dependencies
#RUN npm install

# Copy the rest of your application files to the container
COPY . .

# Create shell script to start the Node.js application
#RUN echo "node app.js &" >> /kali.sh

# Create directory for SSH daemon's runtime files
#RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/kali.sh
#RUN echo "./ngrok tcp 22 &>/dev/null &" >>/kali.sh

# Create directory for SSH daemon's runtime files
RUN mkdir /run/sshd
RUN echo '/usr/sbin/sshd -D' >>/kali.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config # Allow root login via SSH
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config  # Allow password authentication
RUN echo root:${Password}|chpasswd # Set root password
RUN service ssh start
RUN chmod 755 /kali.sh
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
RUN cp ./cloudflared-linux-amd64 /usr/local/bin/cloudflared
RUN chmod +x /usr/local/bin/cloudflared
ENV GOTTY_VERSION=2.0.0-alpha.3
RUN cd /tmp/ && \
    wget https://github.com/yudai/gotty/releases/download/v${GOTTY_VERSION}/gotty_${GOTTY_VERSION}_linux_amd64.tar.gz -O gotty.tar.gz && \
    tar xf gotty.tar.gz && mv gotty /usr/local/bin/ && rm gotty.tar.gz
RUN chmod +x /usr/local/bin/gotty
# Expose ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306
CMD /bin/bash -c "/kali.sh & gotty -p 8080 -w /bin/bash &>/dev/null & cloudflared tunnel --url http://localhost:8080 --hostname trycloudflare.com"
