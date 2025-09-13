#!/bin/sh
#  
#   --filesystem "APFS" \

test -f qping-5g.dmg && rm qping-5g.dmg
create-dmg \
  --volname "qping-5g" \
  --volicon "logo_italtel-analema.icns" \
  --background "dmg-background.tiff" \
  --window-pos 200 120 \
  --window-size 660 440 \
  --icon "qping-5g.app" 200 190 \
  --hide-extension "qping-5g.app" \
  --icon-size 100 \
  --app-drop-link 450 195 \
  "qping-5g.dmg" \
  "./qping-5g"
