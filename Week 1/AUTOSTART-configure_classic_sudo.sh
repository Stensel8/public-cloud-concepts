#!/bin/bash
apt-get update -qq
apt-get install -y sudo nano
update-alternatives --set sudo /usr/bin/sudo.ws
ln -sf /usr/bin/sudo.ws /usr/bin/sudo  # Force symlink (root)
chmod 4755 /usr/bin/sudo  # SUID bit
echo "Persistent classic: $(sudo --version)" > /tmp/sudo-fixed.log
