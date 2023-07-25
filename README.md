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

## Examples:

Synchronizing the PTP Hardware Clock:
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
- `step_threshold` is the maximum offset the servo will correct by changing the clock frequency (phase when using nullf servo) instead of stepping the clock.
- `m` is used to print messages to stdout

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
