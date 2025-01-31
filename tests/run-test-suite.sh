#!/bin/bash -e

# The version of linuxptp-testsuite needs to be correct for the version of LinuxPTP that is being tested.
# linuxptp-testsuite source: https://github.com/mlichvar/linuxptp-testsuite
# More info: https://git.launchpad.net/ubuntu/+source/linuxptp/tree/debian/tests/README
#
# Version compatibility matrix
# linuxptp version  |  linuxptp-testsuite commit id
# ------------------|------------------------------
# v4.0              |  b4763bb
# v4.1              |  248073c
# v4.2              |  bf8eadc
# v4.3              |  d27dbdb (includes 36-automotive)
# v4.4              |  8652e8b

LINUXPTP_TESTSUITE_VERSION="8652e8b"

# The version of clknetsim needs to match the version of the clknetsim.so file that is included in the snap. See snap/snapcraft.yaml.
# https://github.com/mlichvar/clknetsim

CLKNETSIM_VERSION="64acc4fd0ee92c2bafd9d1cf8097eb3632da685b"


sudo snap alias linuxptp.ptp4l ptp4l
sudo snap alias linuxptp.hwstamp-ctl hwstamp_ctl
sudo snap alias linuxptp.nsm nsm
sudo snap alias linuxptp.phc-ctl phc_ctl
sudo snap alias linuxptp.phc2sys phc2sys
sudo snap alias linuxptp.pmc pmc
sudo snap alias linuxptp.timemaster timemaster
sudo snap alias linuxptp.ts2phc ts2phc
sudo snap alias linuxptp.tz2alt tz2alt

# Remove test suite if it already exists, and clone again
rm -rf linuxptp-testsuite
git clone https://github.com/mlichvar/linuxptp-testsuite.git
cd linuxptp-testsuite
git checkout $LINUXPTP_TESTSUITE_VERSION

git clone https://github.com/mlichvar/clknetsim
cd clknetsim
git checkout $CLKNETSIM_VERSION
make
# Replace clknetsim's LD_PRELOAD with a copy of the shared object contained inside the snap, which uses the correct glibc version for the base
sed -i -e 's/LD_PRELOAD=${CLKNETSIM_PRELOAD:+$CLKNETSIM_PRELOAD:}$CLKNETSIM_PATH/CLKNETSIM_SO_PATH=\/snap\/linuxptp\/current/g' clknetsim.bash

cd ..
./run
