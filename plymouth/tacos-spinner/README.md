# Plymouth theme - TacOS with Spinner

# Install Packages

```bash
# dnf install -y plymouth-plugin-two-step plymouth-set-default-theme
```

# Setup

```bash
# cp -rp tacos-spinner /usr/share/plymouth/themes/
# plymouth-set-default-theme tacos-spinner -R
```

For testing:

In one ssh session:
```bash
# plymouthd --no-daemon --debug
```

In another session:

```bash
# plymouth --show-splash && sleep 5
```


