#### Step 1: Install these packages:
`pacman -S fcitx fcitx-mozc fcitx-qt5 kcm-fcitx fcitx-gtk2 fcitx-gtk3`

#### Step 2: Copy this file:
`cp /etc/xdg/autostart/fcitx-autostart.desktop ~/.config/autostart/`

#### Step 3: Open/Create the file `~/.pam_environment` with the text editor of your choice and put this in it:
```
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

#### Step 4: Reboot
#### Step 5: Use the new icon on your taskbar to configure fcitx, and add `mozc` as an input method below your current input method.
