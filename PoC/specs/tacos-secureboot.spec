Name: tacos-secureboot
Version: 0.1.0
Release: %autorelease
Summary: TacOS Custom Secure Boot GRUB and MOK Keys

License: GPLv3+
URL: https://security.nortk.com
Source0: grub2-mkconfig-wrapper

Requires: grub2-efi-x64
Requires: efi-filesystem
Requires: grub2-common

BuildArch: x86_64

%description
Provides the custom, BTRFS-enabled grubx64.efi signed by the NorTK MOK,
and stages the public key for Secure Boot enrollment.

%install
mkdir -p %{buildroot}/usr/libexec/nortk
install -m 0755 %{SOURCE0} %{buildroot}/usr/libexec/nortk/grub2-mkconfig-wrapper

%post
# Divert grub2-mkconfig so it runs mokutil during OEM deployment
if [ ! -f /usr/sbin/grub2-mkconfig.redhat ]; then
    mv /usr/sbin/grub2-mkconfig /usr/sbin/grub2-mkconfig.redhat
    ln -sf ../libexec/nortk/grub2-mkconfig-wrapper /usr/sbin/grub2-mkconfig
fi

# Create a CoW-disabled grubenv for BTRFS compatibility
rm -f /boot/grub2/grubenv
# Recreate it and disable Copy-on-Write
touch /boot/grub2/grubenv
chattr +C /boot/grub2/grubenv
grub2-editenv /boot/grub2/grubenv create
grub2-editenv /boot/grub2/grubenv set blsdir=/boot/loader/entries
grub2-editenv /boot/grub2/grubenv set gfxmode=1920x1080,1024x768,auto
grub2-editenv /boot/grub2/grubenv set gfxpayload=keep
grub2-editenv /boot/grub2/grubenv set GRUB_PRELOAD_MODULES=btrfs

# Create the UEFI Fallback CSV for TacOS
EFI_NORTK_DIR="/boot/efi/EFI/nortk"
mkdir -p "$EFI_NORTK_DIR"
echo -n "shimx64.efi,TacOS,," | iconv -f ASCII -t UTF-16LE > "$EFI_NORTK_DIR/bootx64.csv"

%preun
# Clean up the wrapper if uninstalled
if [ $1 -eq 0 ]; then
    if [ -f /usr/sbin/grub2-mkconfig.redhat ]; then
        rm -f /usr/sbin/grub2-mkconfig
        mv /usr/sbin/grub2-mkconfig.redhat /usr/sbin/grub2-mkconfig
    fi
fi

%files
%dir /usr/libexec/nortk
/usr/libexec/nortk/grub2-mkconfig-wrapper

%license
%doc

%changelog
%autochangelog

