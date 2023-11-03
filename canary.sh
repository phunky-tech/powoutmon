#!/bin/bash

# Get MONITOR_IPS and MONITOR_MACS from .env or $1
if [ -f "$1" ]; then
	source "$1"
else
	source .env
fi
IFS=' ' read -r -a MONITOR_IPS_ARRAY <<<"$MONITOR_IPS"
IFS=' ' read -r -a MONITOR_MACS_ARRAY <<<"$MONITOR_MACS"

# If length of MONITOR_IPS_ARRAY != length of MONITOR_MACS_ARRAY, exit with error
if [ "${#MONITOR_IPS_ARRAY[@]}" -ne "${#MONITOR_MACS_ARRAY[@]}" ]; then
  echo "Error: length of MONITOR_IPS_ARRAY != length of MONITOR_MACS_ARRAY"
  exit 1
fi

# Function to echo a message with the current time
function echoWithTime() {
  echo "PowOutMon_Canary_$(date +%Y-%m-%d_%H:%M:%S) - $1"
}

# For each IP/MAC pair in MONITOR_IPS_ARRAY/MONITOR_MACS_ARRAY
for index in "${!MONITOR_IPS_ARRAY[@]}"; do
  # If IP does not respond to ping within 60 seconds
  if ! ping -c 1 -W 60 "${MONITOR_IPS_ARRAY[index]}" >/dev/null; then
    echoWithTime "Ping to ${MONITOR_IPS_ARRAY[index]} unsuccessful. Sending WOL packet to ${MONITOR_MACS_ARRAY[index]}"
    # Send WOL packet to IP/MAC pair
    wakeonlan -i "${MONITOR_IPS_ARRAY[index]}" "${MONITOR_MACS_ARRAY[index]}"
  else
    echoWithTime "Ping to ${MONITOR_IPS_ARRAY[index]} successful"
  fi
done
