Create `/etc/X11/xorg.conf.d/30-touchpad.conf`, containing:

```c
Section "InputClass"
    Identifier "touchpad catchall"
    Driver "libinput"
    Option "Tapping" "on"
EndSection
```
