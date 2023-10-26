#!/bin/bash

# Get hosts from .env or $1
if [ -f "$1" ]; then
	source "$1"
else
	source .env
fi
IFS=' ' read -r -a HOSTS_ARRAY <<<"$HOSTS"

# Function to echo a message with the current time
function echoWithTime() {
	echo "PowOutMon_$(date +%Y-%m-%d_%H:%M:%S) - $1"
}

numAttempts=0
# If .pomCache does not exist, create it
if [ ! -f .pomCache ]; then
	echoWithTime "Creating .pomCache"
	touch .pomCache
	echo "0" >.pomCache
else
	# Read the number of attempts from .pomCache
	numAttempts=$(cat .pomCache)
fi

# Read the file line by line
for host in "${HOSTS_ARRAY[@]}"; do
	# Ping the host with a timeout of 60 seconds
	if ping -c 1 -W 60 "$host" >/dev/null; then
		echoWithTime "Ping to $host successful."
		# If numAttempts > 0, reset numAttempts to 0 and write it to .pomCache
		if [ "$numAttempts" -gt 0 ]; then
			echoWithTime "Resetting numAttempts to 0 and writing to .pomCache"
			numAttempts=0
			echo "$numAttempts" >.pomCache
		fi
		exit 0
	fi
done

# If we reach this point, none of the hosts responded to ping within 60 seconds
# Increment numAttempts and write it to .pomCache
numAttempts=$((numAttempts + 1))
echoWithTime "None of the hosts responded within 60 seconds. Incrementing numAttempts and writing to .pomCache"
echo "$numAttempts" >.pomCache

# If numAttempts < MAX_ATTEMPTS, increment numAttempts and write it to .pomCache
if [ "$numAttempts" -lt "$MAX_ATTEMPTS" ]; then
	echoWithTime "numAttempts < MAX_ATTEMPTS. Not shutting down."
	exit 0
fi

# If we reach this point, numAttempts >= MAX_ATTEMPTS
echoWithTime "numAttempts >= MAX_ATTEMPTS. Shutting down."
sudo shutdown -h now
