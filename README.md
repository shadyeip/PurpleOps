<h1 align="center">
  <br>
  <a href="https://purpleops.app"><img src="static/images/logo.png" alt="PurpleOps Logo" width="200"></a>
  <br>
  PurpleOps
  <br>
</h1>

<h4 align="center">An open-source self-hosted purple team management web application.</h4>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/Licence-blue?logo=unlicense&logoColor=white">
  <a href="https://docs.purpleops.app"><img src="https://img.shields.io/badge/Docs-blue?logo=readthedocs&logoColor=white">
</p>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#credits">Credit</a> •
  <a href="#license">License</a>
</p>

<p align="center">
  <img src="static/images/demo.gif">
</p>

## Key Features

* Template engagements and testcases
* Framework friendly
* Role-based Access Control & MFA
* Inbuilt DOCX reporting + custom template support
* Simple and secure installation steps - New feature in fork!

How PurpleOps is different:

* No attribution needed
* Hackable, no "no-reversing" clauses
* No over complications with tomcat, redis, manual database transplanting and an obtuce permission model

## Installation

This leverages Docker and an nginx reverse proxy to install and host PurpleOps. 

If a custom SSL certificate is not provided, the installation will genererate self-signed certificates.

### Prereqs

Tested on:
- Debian 12

1. Elevate to root:

  ```bash
  sudo su -
  ```

2. Install depenendencies. It's best to run these commands one by one:

  ```bash
  # Tested on Debian 12
  # installs certbot and other dependencies
  apt update
  apt-get install certbot net-tools apt-transport-https ca-certificates curl software-properties-common git -y

  # install docker
  # download the script
  curl -fsSL https://get.docker.com -o install-docker.sh

  # 2. verify the script's content
  cat install-docker.sh

  # 3. run the script with --dry-run to verify the steps it executes
  sh install-docker.sh --dry-run

  # 4. run the script either as root, or using sudo to perform the installation.
  sudo sh install-docker.sh
  ```

### Installation with Self-Signed Certificates

```bash
# Tested on Debian 12
# Clone this repository
git clone https://github.com/shadyeip/PurpleOps

# Go into the repository
cd PurpleOps

# Run the app with docker (add `-d` to run in background)
sudo docker compose up -d

# PurpleOps should now by available on https://localhost. 443 is exposed so should be accessible via direct IP.
```

### Installation with LetsEncrypt Certificates

TODO

### IP Whitelisting with ufw
  
  ```bash
  sudo apt install ufw -y
  sudo ufw allow 22
  sudo ufw deny 80
  sudo ufw deny 443
  sudo ufw insert 1 allow from 100.100.100.100/24 to any port 443
  sudo ufw enable
  ```

## Credits

- Credit to original PurpleOps developers. This is their project. See fork parent.
- Atomic Red Team [(LICENSE)](https://github.com/redcanaryco/atomic-red-team/blob/master/LICENSE.txt) for sample commands
- [CyberCX](https://cybercx.com.au/) for foundational support

## License

Apache
