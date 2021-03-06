#!/usr/bin/env bash

sleep 10
yum install -y epel-release
yum install -y dkms "kernel-devel-uname-r == $(uname -r)"
tar xvf /tmp/ixgbevf-${VERSION}.tar.gz -C /usr/src/

cat > /usr/src/ixgbevf-${VERSION}/dkms.conf << EOF
PACKAGE_NAME="ixgbevf"
PACKAGE_VERSION="${VERSION}"
CLEAN="cd src/; make clean"
MAKE="cd src/; make BUILD_KERNEL=\${kernelver}"
BUILT_MODULE_LOCATION[0]="src/"
BUILT_MODULE_NAME[0]="ixgbevf"
DEST_MODULE_LOCATION[0]="/updates"
DEST_MODULE_NAME[0]="ixgbevf"
AUTOINSTALL="yes"
EOF

dkms add ixgbevf/$VERSION
dkms build ixgbevf/$VERSION
dkms install ixgbevf/$VERSION

sed -i '/^GRUB\_CMDLINE\_LINUX/s/\"$/\ net\.ifnames\=0\"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

/sbin/dracut -f /boot/initramfs-`uname -r`.img `uname -r`