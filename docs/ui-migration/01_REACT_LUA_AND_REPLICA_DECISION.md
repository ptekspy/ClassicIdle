# React-Lua And Replica Decision

## Decision

Migrate directly to React-Lua and use Replica as the persistent player-data source for React.

Do not create a temporary component framework. Do not make React authoritative for gameplay.

## Why

- The UI surface is small enough to migrate directly.
- Existing UI is already generated from code, so visual values can be copied exactly.
- React makes one-component-per-file and props-based leaf components straightforward.
- Replica is already vendored in the repo.
- A single `PlayerDataProvider` avoids each screen independently subscribing to leaderstats or remotes.

## Required separation

Use Replica context for persistent replicated player data:

- `Gold`
- `Resources`
- `XP`
- `StorageLevel`
- `NPCs`
- `Factory`
- `Quest`

Keep transient presentation state outside Replica:

- open/closed menus
- feedback messages
- focused interaction target
- input mode
- quest wayfinding instances
- build ghost and build placement state
- button hover/pressed state

All actions must continue through existing remotes. Never mutate `usePlayerData()` results.

## React packages

The repo now declares:

```toml
[dependencies]
React = "jsdotlua/react@17.2.1"
ReactRoblox = "jsdotlua/react-roblox@17.2.1"
```

Run:

```bash
wally install
argon build
```

Verify these runtime modules exist:

```txt
ReplicatedStorage.Vendor.React
ReplicatedStorage.Vendor.ReactRoblox
```

If Wally reports that those exact versions are unavailable, select matching React and ReactRoblox versions from the configured Wally registry. Keep both versions identical.

## Replica constraint

Current services mutate profile tables directly. Replica only emits changes made through its setter methods.

The first migration step must therefore add a `PlayerDataReplicaService.Sync(player)` boundary and call it after authoritative mutations. Initially sync top-level snapshots to avoid rewriting every gameplay service in the same change.

Later, gameplay services can move to precise `replica:Set(...)` calls as a separate optimization.

## Done when

- React and ReactRoblox resolve through Wally.
- One owner-only player-data replica exists per loaded player.
- React reads persistent data only through `usePlayerData()`.
- Gameplay actions still use server-validated remotes.
