# PowOutMon

PowOutMon (POWer OUTage MONitor) is a utility to allow devices running on a UPS/backup power supply to detect a power outage, and shut down gracefully in such an event. It works by pinging the provided host(s) at a regular interval to check if they are still alive, but will shut down if they are not. The provided host(s) should be devices that are _not_ connected to backup power, meaning they will be offline in the event of a power outage. If and only if all provided host(s) are offline, then the tool will shut down the host machine.

## Setup

### .env

Create a `.env` file in the same directory as `client.sh`. It should look like so:

```
HOSTS="192.168.1.1 192.168.1.4 192.168.1.37"
MAX_ATTEMPTS=3
```

**HOSTS** should be replaced with an array of IPs of devices to use as canaries in the event of a power outage. They should be online most or all of the time, but not connected to backup power

**MAX_ATTEMPTS** should be set as the number of attempts the script should make to connect before giving up and shutting down the machine.

### Cron

Create a cron job as root (via `sudo crontab -e`) to run the script at a regular interval. The following example checks every 3 minutes.

```
*/3 * * * * /path/to/powoutmon/client.sh
```

> NOTE: The cron job **must** be run as root. This ensures that the script has proper permission to shut down the machine without manual intervention.

## Roadmap/Ideas

- [ ] Add an option to specify a "shutdown script". This could allow for the graceful shutdown of Docker or another sensitive program before forcing a system shutdown to help void corrupt data.
