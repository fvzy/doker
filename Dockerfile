# Use kalilinux/kali-rolling as the base image
FROM kalilinux/kali-rolling

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
RUN apt install ssh wget unzip -y > /dev/null 2>&1
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_16.x focal main" | tee /etc/apt/sources.list.d/nodesource.list > /dev/null
RUN echo "deb-src [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_16.x focal main" | tee -a /etc/apt/sources.list.d/nodesource.list > /dev/null
RUN apt-get update && apt-get install -y nodejs

# Set the working directory for your Node.js application
WORKDIR /app

# Copy your package.json and package-lock.json to the container
COPY package.json package-lock.json ./

# Install Node.js dependencies
RUN npm install

# Copy the rest of your application files to the container
COPY . .

# Create shell script to start the Node.js application
RUN echo "npm start app.js &" >> /kali.sh

# Create directory for SSH daemon's runtime files
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
CMD /bin/sh -c "/kali.sh"
