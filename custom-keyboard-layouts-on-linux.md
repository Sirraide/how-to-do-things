# How to create a custom keyboard layout on linux
Adapted from https://xkbcommon.org/doc/current/user-configuration.html

On Wayland, there is a simpler way to do this: create the directory `~/.config/xkb`, and put your custom layout in `~/.config/xkb/symbols/foo` where `foo` 
is the name of the layout; then, create `~/.config/xkb/rules/evdev.xml` with the following contents:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xkbConfigRegistry SYSTEM "xkb.dtd">
<xkbConfigRegistry version="1.1">
  <layoutList>
    <layout>
      <configItem>
        <name>foo</name>
        <shortDescription>fo</shortDescription>
        <description>Custom Layout</description>
      </configItem>
    </layout>
  </layoutList>
</xkbConfigRegistry>
```
Note that the value of the `<name />` tag must be the name of the file you added to the `symbols` directory.

## Legacy Tutorial
The following are the steps that were required when I recently added my improved Greek keyboard layout ‘`aegreek`’.

1. Actually create the keyboard layout; for the format, see e.g. `/usr/share/X11/xkb/symbols/us`. Alternatively, you can use [xkbgen](https://github.com/Sirraide/xkbdisplay) to generate the layout.
2. Copy your layout to `/usr/share/X11/xkb/symbols/`. E.g. if the file is named `aegreek`, copy it to `/usr/share/X11/xkb/symbols/aegreek`.
3. Modify `/usr/share/X11/xkb/rules/evdev.xml` and `/usr/share/X11/xkb/rules/base.xml` (yes, this file is duplicated for some ungodly reason, and you have to modify both for it to work), adding the following as a new layout anywhere
   ```xml
    <layout>
      <configItem>
        <name>aegreek</name>
        <shortDescription>aegreek</shortDescription>
        <description>Greek (improved)</description>
      </configItem>
      <variantList/>
    </layout>
   ```
   Substitute the name of your keyboard for `aegreek` and update the description to be whatever you want it to be.
3. Modify `/usr/share/X11/xkb/rules/evdev.lst` and `/usr/share/X11/xkb/rules/base.lst` (of course, this file is *also* duplicated), and grep for e.g. ‘custom’ or ‘Wolof’ until you get to this part:
   ```
   tm              Turkmen
   tr              Turkish
   ua              Ukrainian
   pk              Urdu (Pakistan)
   uz              Uzbek
   vn              Vietnamese
   sn              Wolof
   custom          A user-defined custom Layout
   ```
   and add a line for your language like so:
   ```
   aegreek         Greek (improved)
   ```
5. Log out and log back in (or reboot if that doesn’t work).
6. Add the keyboard layout in your system settings; if you’re using KDE, searching for the short name (e.g. `aegreek`) works:
   <img width="1044" height="324" alt="image" src="https://github.com/user-attachments/assets/08f67b83-5d9c-4be7-8944-d6d128ba20ab" />
