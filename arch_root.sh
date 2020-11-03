#1.set timezone and language
echo "begin to set timezone and language......"
#systemdatectl set-timezone Asia/Shanghai
#systemdatectl set-npt true
tzselect
sed -i s/#en_US.UTF-8/en_US.UTF-8/g /etc/locale.gen
sed -i s/#zh_CN.UTF-8/zh_CN.UTF-8/g /etc/locale.gen
sed -i s/#zh_CN.GBK/zh_CN.GBK/g /etc/locale.gen
sed -i s/#zh_CN.GB2312/zh_CN.GB2312/g /etc/locale.gen
locale-gen
#2.install grub
echo "begin to install grub......"
if [ ${INSTALL} = "eufi" ];then
pacman -S grub-efi-x86_64 #os-prober
pacman -S efibootmgr
grub-install --efi-directory=/boot/efi --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
else
pacman -S grub #os-prober
grub-install /dev/${DISK}
grub-mkconfig -o /boot/grub/grub.cfg
fi
echo "installing grub have done!!!"
#3.install video drive
echo "begin to install video driver......"
echo "which one do you want to install?(default install ALL)"
echo "1)intel"
echo "2)ati"
echo "3)nvidia"
echo "4)all"
while read -p '#? ' NUM
do
	if [ -z "${NUM}" ] || [ ${NUM} -eq 1 ] || [ ${NUM} -eq 2 ] || [ ${NUM} -eq 3 ] || [ ${NUM} -eq 4 ];then
		break;
	fi
done
case ${NUM} in
	1)VIDEODRIVER=xf86-video-intel;;
	2)VIDEODRIVER=xf86-video-ati;;
	3)VIDEODRIVER=nvidia;;
	4)VIDEODRIVER="nvidia xf86-video-intel xf86-video-ati";;
	*)VIDEODRIVER="nvidia xf86-video-intel xf86-video-ati";;
esac
pacman -S ${VIDEODRIVER}
echo "installing video driver have done!!!"
#install desktop
echo "begin to install desktop......"
pacman -S xorg xorg-server
pacman -S gnome gnome-extra
systemctl enable gdm
pacman -S ttf-dejavu wqy-zenhei wqy-microhei
pacman -S ibus-googlepinyin
#pacman -S  fcitx-im fcitx-configtool
#echo 'export GTK_IMMODULE=fcitx\n\
#export XMODIFIERS="@im=fcitx"\n\
#export GT_IM_MODULE=fcitx' >>  /etc/bashrc
#gsettings set \
#org.gnome.settings-daemon.plugins.xsetting overrides \
#"{'Gtk/IMModule':<'fcitx'>}"
pacman -S networkmanager
echo "installing desktop have done!!!"
#windows systemfile
echo "begin to install windows systemfile......"
pacman -S ntfs-3g dosfstools
echo "installing windows systemfile have done!!!"
#yarout
echo "begin to install yaourt..."
echo '[archlinuxcn]
SigLevel = Optional TrustAll
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
pacman -Syu yaourt
echo "installing yaourt have done"
#compressed software
echo "begin to install compressed software......"
pacman -S p7zip file-roller unrar
echo "installing compressed software have done!!!"
#browser
echo "begin to install browser......"
pacman -S firefox
echo "installing browser have done!!!"
#vim
echo "begin to install vim"
pacman -S vim
echo "vim has been installed!!!"
#bash-completion
echo "begin to install bash-completion"
pacman -S bash-completion
echo "bash-completion has been installed!!!"
#others
pacman -S mlocate
pacman -S net-tools
#dhcpcd
systemctl enable dhcpcd
#passwd and add user
echo "begin to set passwd and add user......"
echo "please input root passwd:"
passwd
echo "please add user:"
read USER
useradd -m ${USER}
echo "please input ${USER} passwd:"
passwd ${USER}
echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
