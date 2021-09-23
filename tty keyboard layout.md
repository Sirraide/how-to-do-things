1. Add keyboard layout to `/usr/share/kbd/keymaps` (e.g. `/usr/share/kbd/keymaps/test.map.gz`)
2. Unicode keys are entred like so: `U+27e8`
3. Do `loadkeys` w/ absolute path (`loadkeys /usr/share/kbd/keymaps/test.map.gz`) to test it
4. Do `localectl set-keymap --no-convert test` to enable it permanently (do `pacman -Suy systemd` (!) first)
