#!/bin/bash

set -euxo pipefail

#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile


# Fix dracut error
# https://github.com/dracut-ng/dracut-ng/pull/1340/
echo "DRACUT BUG"
sed 's/^get_url_handler//' \
    /usr/lib/dracut/modules.d/90livenet/parse-livenet.sh

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]-[$kiwi_profiles]..."

#======================================
# Branding
#--------------------------------------
# Force hostname
echo "tacos" > /etc/hostname

# Ensure Plymouth uses the nortk theme
if [ -x /usr/sbin/plymouth-set-default-theme ]; then
	/usr/sbin/plymouth-set-default-theme tacos-spinner
fi

#======================================
# Clear machine specific configuration
#--------------------------------------
truncate -s 0 /etc/machine-id

#======================================
# Setup default target
#--------------------------------------
systemctl set-default multi-user.target
systemctl enable sshd.service
systemctl enable NetworkManager.service

#======================================
# Setup GRUB Theme
#--------------------------------------
echo "Configuring GRUB theme..."

# 1. Identify the grub directory (distro-dependent)
if [ -d /boot/grub2 ]; then
    GRUB_DIR="/boot/grub2"
elif [ -d /boot/grub ]; then
    GRUB_DIR="/boot/grub"
fi

# 2. Update /etc/default/grub with the theme path
# We use 'sed' to ensure we don't double-up if the line exists
GRUB_TERMINAL_OUTPUT="gfxterm"
GRUB_GFXMODE=1920x1080x32
THEME_PATH="${GRUB_DIR}/themes/Matrices-circle-window/theme.txt"

if [ -f /etc/default/grub ]; then
    # Remove existing GRUB_THEME lines and append the new one
    sed -i '/^GRUB_THEME=/d' /etc/default/grub
    echo "GRUB_THEME=\"${THEME_PATH}\"" >> /etc/default/grub

    # Optional: Ensure graphics mode is enabled
    sed -i '/^GRUB_TERMINAL=/d' /etc/default/grub
    echo "GRUB_TERMINAL=\"gfxterm\"" >> /etc/default/grub
fi

# 3. Regenerate the actual grub.cfg file
if [ -x "$(command -v grub2-mkconfig)" ]; then
    grub2-mkconfig -o "${GRUB_DIR}/grub.cfg"
elif [ -x "$(command -v grub-mkconfig)" ]; then
    grub-mkconfig -o "${GRUB_DIR}/grub.cfg"
fi

# SSH keys for root
mkdir -p /root/.ssh
chmod 700 /root/.ssh
cat << 'EOF' > /root/.ssh/authorized_keys
# Iván
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1COi+wZvA+7xMj8jYtbqjzHRg+wG1yWIJmTbS8+bIB3u+gwMeC5a7spea7M+wcNSNNak0Hioo/GGya8UfDCHxD4pBwUahOfa7J+UOkolf/g6RRCQJVIBtrygD2qdNN+3JpPsVLCzYm5dCXtQl+EF9c+UdY54WZETdbv7yuZg6txJQJOkvrWDFlqbSKL8Ud7DrYkwbNbg37Nri1ir1TT6AQLAkSu2EWcDNg+gWTDNYDt/ThWq1kxAJaQpiuNonaAj5hHgn8qL8pHBIr3G52AyviDulkpYVJYkUl3/bZuPPNisLsHa0CoiW5qQiwE93pgL8/GUeztd+5KPfnWeJNBD0qlD5kdQ3T5MV8oRwONRahso/TyNlhlE/hTjDiX1bxokLtQXuVW4qwh6KXB3LSNX3V8itqQwUMgSvmLqfnOrgdksN/zH/hV4zEh1M19VIKGSvyCuytf6Wu0W1YZ+laRPM6XFqLqhyeNAArPvS6d86kZt+w/fv9rKzFS/q8NiIEYs= imcsk8@soho2
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCeW5z6IkEm97FSkhUwXXhfullf8NtY4jYTwsmh8DzXT4RH8M/oa87vYjNmtVxi1B8Oq4GIkvYllGz0oAaAWenYPb0rH1Ojq0vtK7HdazkIeHv6SXYYekZBPKUowJ+rSvYRjfF5+mo5foY1IC+fp6bM6sp8psRuYt9/MVdHFN0lklUpRojO14X0sjRU8x5szqQGVS2AUyMoVtqRrrkQVvccbPMeHmtvln6COQY2DhQ1GrdopxyinNflTlg0Wt9kK3MxdtLDMlxJJtns3zlnkDgn+zB6MrBGygQvvvRf0ytxpziZUWL/T9/rpBB0zoJfEn3ej+LBMNseb2iCA+qQvJKMsTsC2zNxVuT/JHDHfsyx0R0GypKMmI8BXf5tHC7qDseEVsa4rdS9pXzMSP4iHI547thQdDNzV7Jtn1+aXOekmweDAfLZJlu7b6F10cM4aHujMasjbXk/DT63mPUuApns7L6tn1+fbY4IymDv4qn47fk//AsTpOniUBwca0DUqIs= imcsk8@fedora
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBq0A0EzkahrPoaUxfQfD3n1DzP23N7mckneF/tVqFPikf+el0KqIiG9y+GZ5FngW2WamXiJ85jz251yBb4JIbdtoYLM2aaZ3WYyC2qs8eWKKzpnjELyIIatsdpx/M21USAVejt1Jhc8E118/l4bhbMFABq0YXo3PBAjxrD2DvG0kQmY33OmFYiGiXSO/upx7d+CtMev/dP4Bc3XMIaAwLzKeb98N6oSrKdqXARKeNgQzOgaJRkUtZKTb2AteAsSHvJRAlGgAerFwhiCxAEUCRFmZfIr/kC4PeNY12BlpRPF4Nu40PIcEi6uAWNF7Awwi59csY8dkihL4ZPnMYgipF8KsmtWeEWNDi8ecCMCYzhM6M55F/OggAlnERNyCGlojq8O5k+l63THrFMEP+5G8AkFVcsZn51FDc355REHB5Fz6MiaqAamOWFF525jsU7i4SbHUnTVsBt5tzanVfv3piFFyhw4VX6z2RReUmW9XD2AYt25fkNRNVgqzeQOd13UU= imcsk8@soho1
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMUSwznfA23iq4HGMFH3cvakCuPg5ioIgg2TlAjlx1hS9t0a2luB/JCfSXU+TMh+feuKuFxrpv6tVp62jom893kujvdpbH4F+acwLupW3+BMTna38ZesD1NsNokO0KQSpgJrh7W0s9KY1x3RVmA6nZ2ZYks+N1RKBdzi4qp9pgkQkkkWBsAZn70hEX4Vtb+jbyy3cT1zQHj74iKQFR6KUu3zGEs5rVytBDlhPYu1Z6KHwbU5u7ZAlvFxAJET/ku1WAnWBM9LQu7jxyOMNNlRiMAy4ptmLnTuirdRROHXDz/frdyatMegg/vY7xTA0pQM17q+tGUWaykJcLWniNUTOGx5icwHOue3n4Lhsn/5YYqjc/XpbDsbuRZ8QE/xUS587AUt99+VeTnbQWOsix41gEa3tjesnM9bogCfTXIDcQibnU8B99rkl1nltEyVbdNnmYF50qGfs+F2TLxytXez6xtwp9wuSdvVB8ab1YLiMjDZBA9Fa0f1e3bweKIqZH6O8= ichavero@sohoflip

# Renich
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWo3RJ88qk1RS+P6b8U+rFJ1GpIxKvWW7AGrgiCx8dK renich@introdesk

EOF
chmod 600 /root/.ssh/authorized_keys

exit 0
