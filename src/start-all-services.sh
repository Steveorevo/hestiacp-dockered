#!/bin/bash

# Get the list of all services
services=`service --status-all`

# Iterate over the list of services
while read -r line; do
  # Check if the service is not running
  if [[ "$line" == *"[ - ]"* ]]; then
    # Extract the service name
    service_name=`echo $line | awk '{print $4}'`
    # Start the service
    service $service_name start
  fi
done <<< "$services"
