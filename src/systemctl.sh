#!/bin/bash

# Swap systemctl for service wrapper for docker compatability
if ( [[ -n "$2" ]] && [[ "$2" =~ (mysql|named|exim4|clamav-daemon|clamav-freshclam|fail2ban|postgresql|^php) ]] ); then
  arg1="$1"
  arg2="$2"

  if [[ "$arg1" == "reload-or-restart" ]]; then
    arg1=restart
  fi
  if [[ "$arg2" == "mysql" ]]; then
    arg2=mariadb
  fi
  service $arg2 $arg1
else
  systemctl3.py "$@"
fi
