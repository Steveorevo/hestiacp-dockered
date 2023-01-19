# HestiaCP-Dockered

> :warning: !!! Note: this repo is in progress; when completed, a release will appear in the release tab.

This repo is for creating a Docker image for a localhost [Hestia Control Panel](https://www.hestiacp.com); an open source Control Panel for web hosting. The intent behind localhost is for development and testing only. This image has been culled and purposely doesn't include certain services that have little or no importance in a locel server environment such as ClamAV, fail2ban, spamassassin, DNS, etc. What is included are options for:

* Apache Server
* Nginx Server
* PHP versions 5.4 to 8.2
* MariaDB, a MySQL compatible database server

You can review the Dockerfile that builds the server and make adjustments to meet your needs. See the section "There are two options to choose from" for the examples of a 'lite' image (the default, and what you will find on docker hub) and an option to install a whole lot more (option #2). But be warned that not all features have been tested and may very well not work at all. Check the issues list for known issues; some of these maybe fix-able; others not so given the practicality behind a Docker environment. 

## Building and running in Docker
Building the image is straight forward by following the commands below. A prebuilt 'lite' image can be found on Docker hub. In order to create HestiaCP, this repo needed to patch a number of items in the original HestiaCP Ubuntu install file; and the installer does this dynamically by downloading the latest HestiaCP installer and applying modifications. Also, it emulates and swaps out `systemctl` commands with some workarounds to get the installer to complete and keep HestiaCP happy. Review the Dockerfile for details.

### To build from the given directory:
```
docker build -t hestiacp_dockered .
```

### To run the built image:
```
docker run -d -p 80:80 -p 443:443 -p 8083:8083 -h cp.code.gdn --name hestiacp_dockered_1 -it hestiacp_dockered
```

### To access the docker command line:
```
docker exec -it hestiacp_dockered_1 /bin/bash
```

### To start all services:
You will need to run this script the first time you create a container from the image; or stop and restart one.
```
/usr/src/start-all-services.sh
```

### To check the status of services:
```
service --status-all
```
&nbsp;
---

## Visit your Hestia Control Panel
You can visit your Hestia Control panel by visiting https://hestiacp.dev.cc. in your web browser. You'll need to accept the self-signed certificate to visit the site and use the following credentials to login:

```
Username: admin
Password: password
```

The `dev.cc` TLD in https://hestiacp.dev.cc is a special domain that always points back to localhost; compliments of https://carnam.net/forever-dev-cc/. So you can use it as a short TLD to build out all your development sites, test out multisite domain mode in WordPress, and just easily create sub-domains and sub-sub-domains on the fly. 

Get started by first creating a new user, login as that user and create your first website by adding a domain; i.e [example.dev.cc](https://example.dev.cc) or [sample.dev.cc](https://sample.dev.cc). Choose whatever domain name you want with the `dev.cc` TLD and it should just work!