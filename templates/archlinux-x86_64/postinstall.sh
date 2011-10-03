#!/bin/bash -e

# var to determine package source
PKGSRC=cd

date > /etc/vagrant_box_build_time

# launch automated install
su -c 'aif -p automatic -c aif.cfg'

# copy over the vbox version file
/bin/cp -f /root/.vbox_version /mnt/root/.vbox_version

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
sed -i 's:^DAEMONS\(.*\))$:DAEMONS\1 sshd rc.vboxadd):' /etc/rc.conf

# install mitchellh's ssh key
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# choose a mirror
sed -i 's/^#\(.*leaseweb.*\)/\1/' /etc/pacman.d/mirrorlist

# update pacman
[[ $PKGSRC == 'cd' ]] && pacman -Syy
[[ $PKGSRC == 'cd' ]] && pacman -S --noconfirm pacman

# upgrade pacman db
pacman-db-upgrade
pacman -Syy

# install some packages
pacman -S --noconfirm glibc git pkg-config fakeroot ruby
gem install --no-ri --no-rdoc chef facter
cd /tmp
git clone https://github.com/puppetlabs/puppet.git
cd puppet
ruby install.rb --bindir=/usr/bin --sbindir=/sbin

# set up networking
[[ $PKGSRC == 'net' ]] && sed -i 's/^\(interface=*\)/\1eth0/' /etc/rc.conf

# Install virtualbox guest additions from repo
pacman -Syu virtualbox-archlinux-additions

# Setup virtualbox modules in rc.conf
sed -i 's:^MODULES\(.*\))$:MODULES\1 vboxguest vboxsf vboxvideo):' /etc/rc.conf

# add to /etc/rc.conf

# clean out pacman cache
pacman -Scc<<EOF
y
y
EOF

# zero out the fs
dd if=/dev/zero of=/tmp/clean || rm /tmp/clean
>>>>>>> [archlinux-x86_64] fixes for use with dual arch iso, also fixing up vbox tools install

# Upgrade to the latest!
pacman -Syu --noconfirm

# leave the chroot
ENDCHROOT

# take down network to prevent next postinstall.sh from starting too soon
/etc/rc.d/network stop

# and reboot!
reboot
