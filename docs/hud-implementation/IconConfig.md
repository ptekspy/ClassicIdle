# Icon Replacement Checklist

All icon assets are centralized in `src/ReplicatedStorage/UI/Config/IconConfig.luau`.

| Key group | Required final art | Ratio | Recommended size |
|---|---|---:|---:|
| Gold, Gems, Fuel | Coin, purple gem, red fuel can | 1:1 | 64x64 |
| Trophy, Level, Wheel, Calendar | Match the reference top bar | 1:1 | 96x96 |
| Earth, Moon | Globe and cratered moon | 1:1 | 128x128 |
| Quest, Gift, Meteor | Rocket quest, wrapped gift, meteor | 1:1 | 96x96 |
| Shop, Build, Rocket, Pets | Match reference action tiles | 1:1 | 128x128 |
| Worlds, Rebirth, Codes, Settings | Match reference action tiles | 1:1 | 128x128 |
| Friends, Backpack, Lock, Collapse | Match reference bottom dock | 1:1 | 128x128 |

Use transparent PNGs, no baked panel background, and enough internal padding to avoid touching the image bounds. Upload replacements to Roblox, then change only the matching `Asset` value in `IconConfig.luau`.
