# This is to be run as a cron job every 2 minutes

# Variables

URL="http://localhost:3000/alive"

# Functions

# Prepend date/time in front of echo
function echoWithTime() {
	echo "PowOutMon_$(date +%Y-%m-%d_%H:%M:%S) - $1"
}

# Ping the server. If it does not respond with an HTTP 200 after 5 tries every 12 seconds, shut down the system
# Otherwise, do nothing

for i in {1..5}
do
  if [ $(curl -s -o /dev/null -w "%{http_code}" $URL) -eq 200 ]
  then
    echoWithTime "Server is up"
    exit 0
  fi
  echoWithTime "No response from server. Attempt $i"
  sleep 12
done

echoWithTime "Server is down. Shutting down system"
# sudo shutdown -h now