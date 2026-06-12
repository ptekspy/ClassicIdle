# Final Validation

## Build and static checks

```bash
wally install
argon build
selene src
```

If `selene src` is not supported by the local configuration, run the repo’s normal Selene command instead.

## Root and lifecycle

- [ ] `PlayerGui.ReactUI` appears exactly once.
- [ ] No screen mounts its own independent root.
- [ ] Resetting three times does not duplicate UI or subscriptions.
- [ ] Rejoining creates fresh roots and subscriptions.
- [ ] Plot release removes world-space roots.
- [ ] No infinite rerender or remount loop appears.

## Replica and context

- [ ] One owner-only `PlayerData` replica exists per player.
- [ ] `usePlayerData()` updates for gold, resources, XP, storage, NPCs, factory, and quest changes.
- [ ] A two-player test confirms clients cannot read each other’s private replica.
- [ ] Components never mutate context data.
- [ ] Purchases, upgrades, collection, and placement still use server remotes.

## Visual parity

- [ ] Position and size match.
- [ ] Colors and transparency match.
- [ ] Font, text size, wrapping, and truncation match.
- [ ] Padding, corners, strokes, and layering match.
- [ ] Visibility timing matches.
- [ ] World UI distances, faces, and adornees match.

## Input and behavior

- [ ] Mouse/keyboard interaction works.
- [ ] Touch interaction works.
- [ ] Gamepad interaction works.
- [ ] Feedback replacement timing works.
- [ ] Quest progress and wayfinding work.
- [ ] Worker hire and upgrades work.
- [ ] Machine menus and upgrades work.
- [ ] Factory shop, hotbar, placement, movement, configuration, and collection work.
- [ ] Resource respawn display works.

## Deletion validation

- [ ] Old imperative GUI creation is removed.
- [ ] Active sell-crate physical UI objects are deleted.
- [ ] No required gameplay part was deleted.
- [ ] No missing-object, `WaitForChild`, or validation errors appear.
- [ ] Play mode after deletion looks and behaves the same.

## Final success condition

Click Play after deleting the documented old UI objects. All gameplay UI is created from componentised code, appears once, behaves the same, and remains server-authoritative.
