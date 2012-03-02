#!/bin/sh
#
# Bootstraps a PRODUCTION machine
#
# bootstrap-server.sh sends this script to a production server, then
# runs it.
#
# This script takes the presumed pristine ubuntu lucid server, and performs
# initial bootstrapping, so that:
#
# 1. the ushahidi user is installed;
# 2. the sbtf-ops repository is checked out; and
# 3. sbtf-bootstrap.sh has been run in the repository
#
# sbtf-bootstrap.sh then takes over and ensures the environment is correctly
# configured, etc.
set -e

if [ $(id -u) != 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

ENVIRONMENT=$1
if [ -z "$ENVIRONMENT" ]; then
	ENVIRONMENT="production"
fi

# Install core packages
echo -n "Updating sources... "
apt-get update -qq
echo "done."

echo -n "Installing core packages... "
apt-get install -y git > /dev/null
echo "done."


# Add ushahidi user
echo -n "Adding ushahidi user... "
echo "ushahidi  ALL=NOPASSWD: /bin/bash /home/ushahidi/sbtf-ops/scripts/sbtf-bootstrap.sh *" > /etc/sudoers.d/ushahidi
chmod 440 /etc/sudoers.d/ushahidi

# Make sure includedir directive is present
if ! grep includedir /etc/sudoers > /dev/null; then
    chmod u+w /etc/sudoers
    echo '#includedir /etc/sudoers.d' >> /etc/sudoers
    chmod u-w /etc/sudoers
fi

useradd -c 'Ushahidi System User' -d /home/ushahidi -m -s /bin/bash -u 5555 -U ushahidi || true
echo "done."

# Clone the repo & run the bootstrap
su - ushahidi -c 'git clone git://github.com/rjmackay/sbtf-ops.git sbtf-ops --branch develop'
su - ushahidi -c "cd sbtf-ops && sudo bash /home/ushahidi/sbtf-ops/scripts/sbtf-bootstrap.sh production"
