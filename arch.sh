#!/bin/bash
dhcpcd
#1.select eufi or mbr
export INSTALL
if [ $# = 1 ] &&  [ $1 = "eufi" ];then
	INSTALL=eufi
	echo "you will install eufi system"
else
	echo "you will install mbr system"
fi
#2.part disk
export DISK
echo "begin to part disk......"
echo "parted disk?(G):"
read  DISK
echo "root parted(G):"
read  ROOT
echo "home parted(G):"
read  HOME
dd if=/dev/zero of=/dev/${DISK} seek=1 count=2047 bs=1b
HOME=`expr ${HOME} + ${ROOT}`G
ROOT=${ROOT}G
echo "root part to:${ROOT}"
echo "home part to:${HOME}"
if [ ${INSTALL} = "eufi" ];then
	parted /dev/${DISK} mklabel gpt
	parted /dev/${DISK} mkpart primary 1M 512M 
	parted /dev/${DISK} mkpart primary ext4 512M ${ROOT} 
	parted /dev/${DISK} mkpart primary ext4 ${ROOT} ${HOME} 
	parted /dev/${DISK} mkpart primary linux-swap ${HOME} 100%
	mkfs.vfat /dev/${DISK}1
	mkfs.ext4 /dev/${DISK}2
	mkfs.ext4 /dev/${DISK}3
	mkswap /dev/${DISK}4
	swapon /dev/${DISK}4
	echo "partting disk all done!!!"
	#3.mount
	mount /dev/${DISK}2 /mnt
	mkdir -p /mnt/boot/efi
	mount /dev/${DISK}1 /mnt/boot/efi
	mkdir /mnt/home
	mount /dev/${DISK}3 /mnt/home
else
	parted /dev/${DISK} mklabel msdos
	parted /dev/${DISK} mkpart primary ext4 1M ${ROOT} 
	parted /dev/${DISK} mkpart primary ext4 ${ROOT} ${HOME} 
	parted /dev/${DISK} mkpart primary linux-swap ${HOME} 100%
	mkfs.ext4 /dev/${DISK}1
	mkfs.ext4 /dev/${DISK}2
	mkswap /dev/${DISK}3
	swapon /dev/${DISK}3
	echo "partting disk all done!!!"
	#3.mount
	mount /dev/${DISK}1 /mnt
	mkdir /mnt/home
	mount /dev/${DISK}2 /mnt/home
fi
#4.change urt software sources
echo "begin to change urt software sources......"
sed -i "1iServer = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch\n\
Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch\n\
Server = https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch\n\
Server = https://mirrors.163.com/archlinux/\$repo/os/\$arch\n\
Server = https://mirrors.xjtu.edu.cn/archlinux/\$repo/os/\$arch" /etc/pacman.d/mirrorlist
echo "changging urt software sources have done!!!"
#5.install archlinux
echo "begin to install archlinux......"
pacstrap /mnt base base-devel
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
echo "installing archlinux have done!!!"
cp ./arch_root.sh /mnt/
arch-chroot /mnt
rm /mnt/arch_root.sh
if [ ${INSTALL} = "eufi" ];then
	umount /mnt/boot/efi
fi
umount /mnt/home
umount /mnt
echo "all have done!!!
BEGIN TO ENJOY ARCH LINUX!!!"
