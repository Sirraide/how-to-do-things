# Setting up a keychron keyboard on linux
Your user needs to have access to the keyboard input device; for that, run
```bash
$ lsusb | grep keychron -i
Bus 001 Device 006: ID 3434:0ea0 Keychron Keychron K10 HE
```
to obtain the vendor and device ID. The, create the file `/etc/udev/rules.d/99-keychron.rules` with contents
```console
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0ea0", MODE="0660", GROUP="ae", TAG+="uaccess", TAG+="udev-acl"
```
and replace `ae` with your username and the values assigned to the `idVendor` and `idProduct` attributes with the vendor and device IDs obtained
from running the grep command above.

You should now be able to navigate to `launcher.keychron.com` and inspect your device.

## Mapping a key to the MENU key
I use the menu key as my 5th level shift modifier; the name of the menu key in the keychron app is `RApp` for some reason (there is also a `Menu`
key but it’s something else entirely apparently).
