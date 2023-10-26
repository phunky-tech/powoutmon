# PowOutMon

PowOutMon (POWer OUTage MONitor) is a utility to allow devices running on a UPS/backup power supply to detect a power outage, and shut down gracefully in such an event. It works by pinging the provided host(s) at a regular interval to check if they are still alive, but will shut down if they are not. The provided host(s) should be devices that are _not_ connected to backup power, meaning they will be offline in the event of a power outage. If and only if all provided host(s) are offline, then the tool will shut down the host machine.

## Monitor Setup

The following setup relates to `monitor.sh` and should be run on any machines connected to a UPS.

### .env

Create a `.env` file in the same directory as `monitor.sh`. It should look like so:

```
HOSTS="192.168.1.1 192.168.1.4 192.168.1.37"
MAX_ATTEMPTS=3
```

**HOSTS** should be replaced with an array of IPs of devices to use as canaries in the event of a power outage. They should be online most or all of the time, but not connected to backup power

**MAX_ATTEMPTS** should be set as the number of attempts the script should make to connect before giving up and shutting down the machine.

### Cron

Create a cron job as root (via `sudo crontab -e`) to run the script at a regular interval. The following example checks every 3 minutes.

```
*/3 * * * * /path/to/powoutmon/monitor.sh /path/to/powoutmon/.env
```

> NOTE: The cron job **must** be run as root. This ensures that the script has proper permission to shut down the machine without manual intervention.

## Canary Setup

The following setup relates to `canary.sh` and should be run on any machines that are **not** connected to a UPS and that are set to turn on automatically when power is restored.

### .env

Create a `.env` file in the same director as `monitor.sh`. It should look like so:

```
MONITOR_IPS="192.168.1.4 192.168.1.27"
MONITOR_MACS="FF:FF:FF:FF:FF:FF FF:FF:FF:FF:FF:FF"
```

Replace the ips and macs with your real ips and macs. The values in any given index should correspond to the same machine between the two (i.e. `MONITOR_IPS[1]` and `MONITOR_MACS[1]` both belong to the same device).

### Cron

Create a cron job (via `crontab -e`) to run the script at a regular interval. The following example checks every 5 minutes.

```
*/5 * * * * /path/to/powoutmon/canary.sh /path/to/powoutmon/.env
```

Done!

## Roadmap/Ideas

- [ ] Add an option to specify a "shutdown script". This could allow for the graceful shutdown of Docker or another sensitive program before forcing a system shutdown to help void corrupt data.
- [x] Add a "canary" script to send a WoL (Wake on LAN) reqeuest to specific hosts if they are offline. This would be helpful for when power comes back online, since devices connected to a UPS would have no way of knowing.
