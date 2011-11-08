#!/bin/bash -x

date > /etc/vagrant_box_build_time

# launch automated install
su -c 'aif -p automatic -c aif.cfg'

# choose the mirror we setup in aif
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

# copy over the vbox version file
mkdir -p /mnt/root
/bin/cp -f /root/.vbox_version /mnt/root/.vbox_version
vbox_version=$(cat /root/.vbox_version)

# chroot into the new system
mount -o bind /dev /mnt/dev
mount -o bind /sys /mnt/sys
mount -t proc none /mnt/proc
chroot /mnt <<ENDCHROOT

# make sure network is up and a nameserver is available
dhcpcd eth0

# sudo setup
# note: do not use tabs here, it autocompletes and borks the sudoers file
cat <<EOF > /etc/sudoers
root    ALL=(ALL)    ALL
%wheel    ALL=(ALL)    NOPASSWD: ALL
EOF

# set up user accounts
passwd<<EOF
vagrant
vagrant
EOF
useradd -m -G wheel -r vagrant
passwd -d vagrant
passwd vagrant<<EOF
vagrant
vagrant
EOF

# create puppet group
groupadd puppet

# make sure ssh is allowed
echo "sshd:	ALL" > /etc/hosts.allow

# and everything else isn't
echo "ALL:	ALL" > /etc/hosts.deny

# make sure sshd starts
sed -i 's:^DAEMONS\(.*\))$:DAEMONS\1 sshd):' /etc/rc.conf

# install mitchellh's ssh key
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# update pacman
pacman -Syy
pacman -S --noconfirm pacman

# upgrade pacman db
pacman-db-upgrade
pacman -Syy

pacman -S --noconfirm ruby git yajl

# install some packages
gem install --no-ri --no-rdoc chef
gem install --no-ri --no-rdoc puppet

# host-only networking
cat >> /etc/rc.local <<EOF
# enable DHCP at boot on eth0
# See https://wiki.archlinux.org/index.php/Network#DHCP_fails_at_boot
dhcpcd eth0
EOF

# install yaourt
wget http://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
tar -xzvf package-query.tar.gz
cd package-query
makepkg -s --asroot --install --noconfirm
cd ..
wget http://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
tar -xzvf yaourt.tar.gz
cd yaourt
makepkg -s --asroot --install --noconfirm

pacman -S --noconfirm virtualbox-archlinux-additions 

# clean out pacman cache
#pacman -Scc<<EOF
#y
#y
#EOF

# Upgrade to the latest!
#pacman -Syu --noconfirm

# zero out the fs
dd if=/dev/zero of=/tmp/clean || rm /tmp/clean

ENDCHROOT

# and reboot!
reboot
