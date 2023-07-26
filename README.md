# LinuxPTP Snap

## Build:
```bash
snapcraft -v
```

## Install:
```bash
snap install --devmode *.snap
```

## Info:
```bash
$ snap info linuxptp-rt
name:      linuxptp-rt
summary:   Linux Precision Time Protocol (PTP)
publisher: –
license:   GPL-2.0-only
description: |
  Snap packaging for linuxptp,
  an implementation of the Precision Time Protocol (PTP) according to IEEE standard 1588 for Linux.
commands:
  - linuxptp-rt.hwstamp-ctl
  - linuxptp-rt.nsm
  - linuxptp-rt.phc-ctl
  - linuxptp-rt.phc2sys
  - linuxptp-rt.pmc
  - linuxptp-rt.ptp4l
  - linuxptp-rt.timemaster
  - linuxptp-rt.ts2phc
  - linuxptp-rt.tz2alt
refresh-date: today at 11:36 CEST
installed:    v4.0+snap (x4) 413kB devmode
```

## Usage:
```bash
$ linuxptp-rt.ptp4l
no interface specified

usage: ptp4l [options]

 Delay Mechanism

 -A        Auto, starting with E2E
 -E        E2E, delay request-response (default)
 -P        P2P, peer delay mechanism

 Network Transport

 -2        IEEE 802.3
 -4        UDP IPV4 (default)
 -6        UDP IPV6

 Time Stamping

 -H        HARDWARE (default)
 -S        SOFTWARE
 -L        LEGACY HW

 Other Options

 -f [file] read configuration from 'file'
 -i [dev]  interface device to use, for example 'eth0'
           (may be specified multiple times)
 -p [dev]  Clock device to use, default auto
           (ignored for SOFTWARE/LEGACY HW time stamping)
 -s        client only synchronization mode (overrides configuration file)
 -l [num]  set the logging level to 'num'
 -m        print messages to stdout
 -q        do not print messages to the syslog
 -v        prints the software version and exits
 -h        prints this message and exits
```

Connect interfaces to access desired resources::

```bash
# Access to network setting
snap connect linuxptp-rt:network-control
# Access to system date and time
snap connect linuxptp-rt:time-control

# Access to system logs and data
snap connect linuxptp-rt:system-backup  
snap connect linuxptp-rt:log-observe   

# Access to PTP subsystem and files
snap connect linuxptp-rt:ptp
snap connect linuxptp-rt:system-dev-pts
snap connect linuxptp-rt:system-dev-ptp0 
```

## Examples:

### ptp4l - synchronize the PTP Hardware Clock (PHC):
```bash
$ sudo linuxptp-rt.ptp4l -i eno1 -f /snap/linuxptp-rt/current/usr/share/doc/linuxptp/configs/gPTP.cfg --step_threshold=1 -m
ptp4l[10992.160]: selected /dev/ptp0 as PTP clock
ptp4l[10992.246]: port 1 (eno1): INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[10992.247]: port 0 (/var/run/ptp4l): INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[10992.247]: port 0 (/var/run/ptp4lro): INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[10995.795]: port 1 (eno1): LISTENING to MASTER on ANNOUNCE_RECEIPT_TIMEOUT_EXPIRES
ptp4l[10995.795]: selected local clock 04421a.fffe.078056 as best master
ptp4l[10995.795]: port 1 (eno1): assuming the grand master role
```

where:
- `eno1` is interface device to use
- `/snap/linuxptp-rt/current/usr/share/doc/linuxptp/configs/gPTP.cfg` is the configuration file
- `step_threshold` is the maximum offset the servo will correct by changing the clock frequency (phase when using nullf servo) instead of stepping the clock
- `m` is used to print messages to stdout

### nsm - NetSync Monitor (NSM) client
TBA

### pmc - synchronize the system clock:
```bash
$ sudo linuxptp-rt.pmc -u -b 0 -t 1 "SET GRANDMASTER_SETTINGS_NP clockClass 248 \
        clockAccuracy 0xfe offsetScaledLogVariance 0xffff \
        currentUtcOffset 37 leap61 0 leap59 0 currentUtcOffsetValid 1 \
        ptpTimescale 1 timeTraceable 1 frequencyTraceable 0 \
        timeSource 0xa0"
sending: SET GRANDMASTER_SETTINGS_NP
```

where:
- `u` is used to select the Unix Domain Socket transport
- `b` is used to specify the boundary hops value in sent messages
- `t` is used to specify the transport specific field in sent messages as a hexadecimal number.


### phc2sys - synchronize the System clock with PHC:
```bash
$ sudo linuxptp-rt.phc2sys -s eno1 -c CLOCK_REALTIME --step_threshold=1 --transportSpecific=1 -w -m
```
TBA, need access to /run/phc2sys.*

### hwstamp-ctl - enable hardware timestamping:
```bash
$ sudo linuxptp-rt.hwstamp-ctl -i eno1 -t 1 -r 9
current settings:
tx_type 1
rx_filter 12
new settings:
tx_type 1
rx_filter 12
```
where:
- `eno1` is interface device to use
- `t` is whether enable or disable hardware time stamping for outgoing packets
- `r` is the type of incoming packets should be time stamped

### phc_ctl - control a PHC clock:
```bash
$ sudo linuxptp-rt.phc-ctl eno1 get
phc_ctl[45040.084]: clock time is 1689781163.846408401 or Wed Jul 19 17:39:23 2023
```
where:
- `eno1` is the interface device to use
- `get` is the command to get the current time of the PHC clock device



### Timemaster - run Network Time Protocol (NTP) with Precision Time Protocol (PTP) as reference clocks:
```bash
sudo linuxptp-rt.timemaster -f /etc/linuxptp/timemaster.conf 
```
TBA, need relocate timemaster.conf under snap file location

### ts2phc - synchronize one or more PTP Hardware Clocks using external time stamps:

```bash
$ sudo linuxptp-rt.ts2phc -c eno1 -m
```
TBA

### tz2alt - monitor daylight savings time changes and publishes them to PTP stack:
```bash
$ sudo linuxptp-rt.tz2alt -z Europe/Berlin --leapfile /usr/share/zoneinfo/leap-seconds.list
```
TBA, needs access to /run/tztool.*
## Alias

Add [alias](https://snapcraft.io/docs/commands-and-aliases) to run the command without the namespace:
```
$ snap alias linuxptp-rt.ptp4l ptp4l
Added:
  - linuxptp-rt.ptp4l as ptp4l
```

```bash
$ ptp4l -v
4.0
 ```

 ## References
 - https://manpages.debian.org/unstable/linuxptp/ptp4l.8.en.html
 - https://tsn.readthedocs.io/timesync.html
