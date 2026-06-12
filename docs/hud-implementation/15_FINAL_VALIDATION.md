# Final Validation

## Build and boot

```bash
wally install
argon build
selene src
```

Start Play mode and confirm no errors, warnings, infinite rerenders, or missing assets.

## Desktop visual contract

At `1920x1080`, compare a screenshot directly against the reference:

- [ ] Top order is Gold, Gems, Fuel, Best Distance, Level/XP, Wheel, Calendar.
- [ ] Zone bar is centered beneath the top bar.
- [ ] Left order is Main Quest, Daily Reward, Limited Event.
- [ ] Right rail is the exact two-column reference order.
- [ ] Bottom order is Invite Friends, Collapse, Hotbar, Backpack, Launch.
- [ ] Labels, demo values, badges, and progress values match.
- [ ] `HUD DESIGN 4` is absent.

## Responsive matrix

Test:

```txt
1920x1080
1366x768
1280x720
1024x768
844x390
390x844
```

For every size:

- [ ] No overlap or clipped functional control.
- [ ] Functional touch targets remain at least 44x44.
- [ ] Hidden items follow lesson 07 priority rules.
- [ ] Text truncates or wraps without escaping panels.

## Live data and behavior

- [ ] Gold updates from Replica.
- [ ] XP updates Level and XP progress.
- [ ] Quest title/progress updates from the existing quest controller.
- [ ] Quest world marker remains functional.
- [ ] Factory inventory updates hotbar slots.
- [ ] Build opens the existing build shop.
- [ ] Hotbar selection starts existing placement behavior.
- [ ] Build controls and factory management remain functional.
- [ ] Feedback, interaction, worker, and machine overlays remain above the HUD.

## Disabled-feature contract

Click and gamepad-select every placeholder:

- [ ] Gems plus, Fuel plus, Gold plus
- [ ] Wheel, Calendar, zone progress
- [ ] Daily Claim and Join Event
- [ ] Shop, Rocket, Pets, Worlds, Rebirth, Codes, Settings
- [ ] Invite Friends, Collapse, Backpack, Launch, locked hotbar slot

None may fire a callback, remote, warning, or navigation action.

## Lifecycle

- [ ] Exactly one `PlayerGui.ReactUI` root exists.
- [ ] Reset character three times; HUD remains exactly once.
- [ ] Rejoin; subscriptions and roots are fresh.
- [ ] No screen mounts an independent root.

## Final success condition

The HUD matches the reference at desktop size, responds safely on smaller screens, uses the shared design system without duplicated styling, and preserves all existing ClassicIdle behavior.
