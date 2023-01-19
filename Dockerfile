FROM ubuntu:22.04

# Update and upgrade the system
RUN apt-get update && apt-get upgrade -y

# Install basic utilities
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y sudo wget curl nano git unzip lsb-core php
RUN apt remove -y apparmor
COPY src/start-all-services.sh /usr/src/start-all-services.sh
RUN chmod +x /usr/src/start-all-services.sh

#Install systemd and journalctl replacements
COPY src/docker-systemctl-replacement/journalctl3.py /usr/bin/journalctl3.py
COPY src/docker-systemctl-replacement/systemctl3.py /usr/bin/systemctl3.py
COPY src/systemctl.sh /usr/bin/systemctl.sh
RUN chmod +x /usr/bin/journalctl3.py
RUN chmod +x /usr/bin/systemctl3.py
RUN chmod +x /usr/bin/systemctl.sh
RUN mv /usr/bin/journalctl /usr/bin/journalctl.original || true
RUN mv /usr/bin/systemctl /usr/bin/systemctl.original || true
RUN ln /usr/bin/journalctl3.py /usr/bin/journalctl
RUN ln /usr/bin/systemctl.sh /usr/bin/systemctl

# Download latest HestiaCP Ubuntu installer using curl
WORKDIR /usr/src
RUN curl -sSL https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install-ubuntu.sh -o hst-install-ubuntu.sh

# Give execute permission to the file
RUN chmod +x hst-install-ubuntu.sh

# Copy our patch to the container and apply it
COPY src/patch-hst-install-ubuntu.sh /usr/src/patch-hst-install-ubuntu.sh
RUN chmod +x patch-hst-install-ubuntu.sh
RUN ./patch-hst-install-ubuntu.sh

# There is no syslog driver, but create the auth.log file to avoid errors
RUN touch /var/log/auth.log

#
# There are two options to choose from:
# 1) The 'lite' installer omits the heavier services not needed for local development
#    such as clamav, named, fail2ban, iptables, etc. This is the default, recomended option.
# 2) The fully patched installer installs all services.
# 
# Choose one of the options by uncommenting/commenting # 1 or # 2 below:
#

# 1 - Run the 'lite' installer silently
RUN ./hst-install-ubuntu.sh --apache yes --phpfpm yes --multiphp yes --vsftpd yes --proftpd no --named no --mysql yes --postgresql yes --exim yes --dovecot yes --sieve no --clamav no --spamassassin no --iptables no --fail2ban no --quota no --api yes --interactive no --with-debs no  --port '8083' --hostname 'hestiacp.dev.cc' --email 'info@domain.tld' --password 'password' --lang 'en' --force --interactive no || true

# 2 - Run the fully patched installer silently
#RUN ./hst-install-ubuntu.sh --apache yes --phpfpm yes --multiphp yes --vsftpd yes --proftpd no --named yes --mysql yes --postgresql yes --exim yes --dovecot yes --sieve no --clamav yes --spamassassin yes --iptables yes --fail2ban yes --quota yes --api yes --interactive no --with-debs no  --port '8083' --hostname 'hestiacp.dev.cc' --email 'info@domain.tld' --password 'password' --lang 'en' --force --interactive no || true


# Fix phpPgAdmin issues; (discussion at: https://forum.hestiacp.com/t/project-to-run-hestia-in-docker/)
RUN unlink /usr/share/phppgadmin/conf/config.inc.php
RUN cp /etc/phppgadmin/config.inc.php /usr/share/phppgadmin/conf/config.inc.php
RUN rm /usr/share/phppgadmin/classes/database/Connection.php
RUN wget -O /usr/share/phppgadmin/classes/database/Connection.php https://raw.githubusercontent.com/Steveorevo/phppgadmin/master/classes/database/Connection.php

# Expose the port to run the application
EXPOSE 80
EXPOSE 443
EXPOSE 8083
