# LinuxPTP Snap


### Build
```bash
snapcraft -v
```

### Install
```bash
snap install --dangerous *.snap
```

### Configure
The default config files are placed under `/snap/linuxptp-rt/current/etc`:
```
/snap/linuxptp-rt/current/etc
├── automotive-master.cfg
├── automotive-slave.cfg
├── default.cfg
├── E2E-TC.cfg
├── G.8265.1.cfg
├── G.8275.1.cfg
├── G.8275.2.cfg
├── gPTP.cfg
├── P2P-TC.cfg
├── ptp4l.conf
├── snap.cfg
├── snmpd.conf
├── timemaster.conf
├── ts2phc-generic.cfg
├── ts2phc-TC.cfg
├── UNICAST-MASTER.cfg
└── UNICAST-SLAVE.cfg
```
The configuration files are sourced from two locations:
- LinuxPTP's [source code](https://github.com/richardcochran/linuxptp)
- This repo (ptp4l.conf and timemaster.conf). These files have been taken from the linuxptp_3.1.1-3_amd64.deb package from Ubuntu archives.

Grant access to necessary resources:
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
```

Add [aliases](https://snapcraft.io/docs/commands-and-aliases) to run the commands without the namespace.For example:
```bash
$ snap alias linuxptp-rt.ptp4l ptp4l
Added:
  - linuxptp-rt.ptp4l as ptp4l

$ which ptp4l
/snap/bin/ptp4l

$ ptp4l -v
4.0
```


For usage examples, refer to the wiki.

## To Do
- [ ] Fix ts2phc permission error - see examples in wiki
- [ ] Check ptp4l and ptp4lro paths - config files point to /var/run/* but system interface is for /run/*
- [ ] Clarify chronyd and ntpd dependencies for timemaster - see its config file

## Usage examples

**In the following examples, `eth0` is the Ethernet interface name.**

### ptp4l
Synchronize the PTP Hardware Clock (PHC):
```bash
$ sudo linuxptp-rt.ptp4l -i eth0 -f /snap/linuxptp-rt/current/etc/gPTP.cfg --step_threshold=1 -m
ptp4l[10992.160]: selected /dev/ptp0 as PTP clock
ptp4l[10992.246]: port 1 (eth0): INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[10992.247]: port 0 (/var/run/ptp4l): INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[10992.247]: port 0 (/var/run/ptp4lro): INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[10995.795]: port 1 (eth0): LISTENING to MASTER on ANNOUNCE_RECEIPT_TIMEOUT_EXPIRES
ptp4l[10995.795]: selected local clock 04421a.fffe.078056 as best master
ptp4l[10995.795]: port 1 (eth0): assuming the grand master role
```

where:
- `-f` is set to the gPTP configuration file in the snap

### nsm
NetSync Monitor (NSM) client:
```bash
$ sudo linuxptp-rt.nsm -i eth0 -f /snap/linuxptp-rt/current/etc/ptp4l.conf 
```


### pmc
Configure the system's UTC-TAI offset (leap seconds):
```bash
$ sudo linuxptp-rt.pmc -u -b 0 -t 1 \
  -s /run/snap.linuxptp-rt/ptp4l \
  -i /run/snap.linuxptp-rt/pmc.$pid \
        "SET GRANDMASTER_SETTINGS_NP clockClass 248 \
        clockAccuracy 0xfe offsetScaledLogVariance 0xffff \
        currentUtcOffset 37 leap61 0 leap59 0 currentUtcOffsetValid 1 \
        ptpTimescale 1 timeTraceable 1 frequencyTraceable 0 \
        timeSource 0xa0"
sending: SET GRANDMASTER_SETTINGS_NP
```

where:
- `-u` specifies the usage of Unix Domain Sockets for inter process communication
- `-i` is set to change the default Unix Domain Socket for PTP Management Client
- `-s` is set to change the default PTP Server Unix Domain Socket


### phc2sys
Run `ptp4l` and synchronize the system clock with PHC:
```bash
$ sudo linuxptp-rt.phc2sys -s eth0 -c CLOCK_REALTIME --step_threshold=1 --transportSpecific=1 -w -m -z /run/snap.linuxptp-rt/ptp4l
phc2sys[2429.376]: CLOCK_REALTIME phc offset 37488402189 s0 freq    +781 delay      0
phc2sys[2430.376]: CLOCK_REALTIME phc offset 37488450430 s1 freq  +48990 delay      0
phc2sys[2431.377]: CLOCK_REALTIME phc offset 37498466839 s0 freq  +48990 delay      0
phc2sys[2432.377]: CLOCK_REALTIME phc offset 37498427594 s0 freq  +48990 delay      0
phc2sys[2433.378]: CLOCK_REALTIME phc offset 37498388319 s1 freq   +9735 delay      0
^C
```

where:
- `-z` sets the server address for UDS


### hwstamp-ctl
Enable hardware timestamping:
```bash
$ sudo linuxptp-rt.hwstamp-ctl -i eth0 -t 1 -r 9
current settings:
tx_type 1
rx_filter 12
new settings:
tx_type 1
rx_filter 12
```

### phc_ctl
Control a PHC clock:
```bash
$ sudo linuxptp-rt.phc-ctl eth0 get
phc_ctl[45040.084]: clock time is 1689781163.846408401 or Wed Jul 19 17:39:23 2023
```

### 🚧 timemaster
Run Network Time Protocol (NTP) with PTP as reference clocks:
```bash
$ sudo linuxptp-rt.timemaster -f /var/snap/linuxptp-rt/common/timemaster.conf -m 
timemaster[5368.389]: failed to spawn /usr/sbin/chronyd: No such file or directory
timemaster[5368.389]: exiting
```

### ts2phc
Synchronize one or more PTP Hardware Clocks (PHC) using external time stamps (GPS) or another PHC. Not all hardware support setting the PHC, so this command may fail with the error `PTP_EXTTS_REQUEST2 failed: Operation not supported`.

```bash
$ sudo linuxptp-rt.ts2phc -c enp0s30f4 -m
ts2phc[4331812.338]: UTC-TAI offset not set in system! Trying to revert to leapfile
^C
```

### tz2alt
Monitor daylight savings time changes and publishes them to PTP stack:
```bash
$ sudo linuxptp-rt.tz2alt -z Europe/Berlin --leapfile /usr/share/zoneinfo/leap-seconds.list
tz2alt[70278.242]: truncating time zone display name from Europe/Berlin to Berlin
tz2alt[70278.245]: next discontinuity Wed Jul 26 17:03:22 2023 Europe/Berlin
```

## References
 - https://manpages.debian.org/unstable/linuxptp/index.html
 - https://tsn.readthedocs.io/timesync.html
