# How to manually install mods for Baldur’s Gate 3 on Linux

## Installing the script extender
1. Download the script extender.
2. Go to `"~/.local/share/Steam/steamapps/common/Baldurs Gate 3/bin"`
3. Copy the `DWrite.dll` that is the script extender into this directory.
4. In steam, modify the command line for Baldur’s Gate 3 to be `WINEDLLOVERRIDES="DWrite.dll=n,b" PROTON_NO_ESYNC=1 %command%`.

## Installing a mod
1. Go to `"~/.local/share/Steam/steamapps/compatdata/1086940/pfx/drive_c/users/steamuser/AppData/Local/Larian Studios/Baldur's Gate 3"`
2. Create a `Mods` directory if it doesn’t already exist.
3. Download the mod you want to install. It should be a `.zip` file containing a `.pak` file and a JSON file. (Some mod authors are also nice enough to provide you w/ the XML tag that you need to copy-paste below)
4. Put the `.pak` file in the `Mods` directory.
5. Now, we need to tell the game to load the mod. For this, we need to edit an XML file. Go to `"~/.local/share/Steam/steamapps/compatdata/1086940/pfx/drive_c/users/steamuser/AppData/Local/Larian Studios/Baldur's Gate 3/PlayerProfiles/Public"`
6. Open `modsettings.xml`. The game likes to overwrite this file, so make it read-only (e.g. set the owner to `root` and `chmod 644` it). NOTE: The game will show an error popup and complain that it couldn’t overwrite the file when you start it (which is exactly what we want); just ignore the error; it will still work just fine.
7. Copy the entire `<node = id="ModuleShortDesc">` tag that has ‘GustavDev’ in some of its `<attribute>` tags; this is provided by the devs and should always be there. Paste the copy after it.
8. Here, we need to change some of the `value` attributes in the `<attribute>` tags. Consult the mod’s JSON file to figure out what values to set these to. If the mod author was nice enough to provide this information in XML form, just use that instead.
9. Start the game and see if it worked.

## Load order
1. In the `<children>` tag of the `<node id="root">` tag, add a `ModOrder` node:
```xml
<node id="root">
   <children>
       <node id="ModOrder">
           <children>
           <!-- Add mods here -->
           </children>
       </node>
...
```
2. Then, add the mods where shown above. E.g.
```xml
<node id="Module">
    <attribute id="UUID" value="<mod uuid goes here>" type="FixedString" />
</node>
```
