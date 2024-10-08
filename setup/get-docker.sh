#!/bin/sh -ex

# Silence the echo of commands
{ set +x; } 2>/dev/null

# Setup colors
RED="\e[31m"
GREEN="\e[32m"
BOLDGREEN="\e[1;${GREEN}"
BOLDRED="\e[1;${RED}"
ENDCOLOR="\e[0m"
PLUS="${BOLDGREEN}[+]${ENDCOLOR}"
ERROR="${BOLDRED}[!]${ENDCOLOR}"

ask_docker_group() {
    printf "${PLUS} Do you want to be added to the docker group (Y/n)? "
    read -r answer
    if [ X$answer != X"n" ]; then
        sudo usermod -aG docker $USER
        echo "${PLUS} You have been added to the docker user group."
        echo "${PLUS} Please log out and log back in for permissions to apply. This terminal will work with Docker, others won't until logout. Mitigate this by running \"newgrp docker\" in each terminal if you can't log out."
        newgrp docker
    else
        echo "${ERROR} You have not been added to the Docker group"
    fi
}

is_docker_installed() {
    echo "${PLUS} Checking if Docker is already installed..."
    # Check if the docker binary exists
    if command -v docker > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Introduction
echo "-------------------------"
echo "| Docker Install Script |"
echo "-------------------------\n"

# Check if running WSL
if uname -a | grep -q "WSL"; then
    echo "${ERROR} You are running inside of WSL, install Docker Desktop on Windows and enable the WSL integration: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Check if running MacOS
if uname -s | grep -q "Darwin"; then
    echo "${ERROR} You are running MacOS. Please install Docker Desktop manually: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Check if running with root permissions
if [ $(id -u) -eq 0 ]; then
    echo "${PLUS} Running as root"
else
    echo "${ERROR} Please run as sudo/root."
    exit 1
fi

# Check if Docker is already installed
if is_docker_installed; then
    echo "${ERROR} Docker is already installed"
    # Ask if they want to reinstall
    printf "${PLUS} Do you want to reinstall Docker (Y/n)? "
    read -r answer
    if [ X$answer = X"n" ]; then
        echo "${ERROR} Aborting..."
        exit 1
    else
        echo "${PLUS} Removing old Docker install..."
        # Remove all of old Docker install, order is particular
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
        # Then do generic Docker removal
        sudo apt purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras -y
        # Ask if they want to remove all Docker data
        printf "${PLUS} Do you want to remove all Docker data [WARNING: This will remove all images, containers, volumes, etc.] (Y/n)? "
        read -r answer
        if [ X$answer = X"n" ]; then
            echo "${PLUS} Keeping Docker data..."
        else
            echo "${PLUS} Removing all Docker data..."
            sudo rm -rf /var/lib/docker
            sudo rm -rf /var/lib/containerd
            echo "${PLUS} Docker data removed"
        fi
        echo "${PLUS} Docker removed. Please reboot and run this script again to install Docker."
        exit 0
    fi
else
    echo "${PLUS} Docker not installed"
fi

# Make sure user is ready to proceed
printf "${PLUS} Checks passed... Proceed (Y/n)? "
read -r answer
if [ X$answer = X"n" ]; then
    echo "${ERROR} Aborting..."
    exit 1
fi

# Check if the current distribution is Kali Linux
# Kali uses a different Docker install process
if grep -q "Kali" /etc/os-release; then
    # Setup curl and keyring requirements
    apt update
    apt install ca-certificates curl gnupg -y
    # Add APT sources/keyring
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    bullseye stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    # Update APT manifest and install Docker
    apt update
    apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    ask_docker_group

# Check if using Alpine
elif grep -q "Alpine" /etc/os-release; then
    # Alpine has a more complicated install
    grep -qE '(http|https)://dl-cdn.alpinelinux.org/alpine/.*/community' /etc/apk/repositories || echo 'http://dl-cdn.alpinelinux.org/alpine/latest-stable/community' >> /etc/apk/repositories && \
    apk update && \
    apk add openrc && \
    apk add docker docker-compose && \
    rc-update add docker default && \
    service docker start

# If running a (probably) normal Linux OS
else
    # Use the Docker convenience script
    sudo sh install-docker.sh
    ask_docker_group
fi
echo "${PLUS} Docker install complete!"