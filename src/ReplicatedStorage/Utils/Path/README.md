# Path

Utilities for reading and writing nested table values with dot-separated paths.

## Usage

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Path = require(ReplicatedStorage.Packages.Utils.Path)
```

### `Path.GetValue(source, path)`

Reads a nested value. It returns `nil` when a key is missing or an intermediate
value is not a table.

```lua
local data = {
	Player = {
		Stats = {
			Coins = 125,
		},
	},
}

print(Path.GetValue(data, "Player.Stats.Coins")) -- 125
print(Path.GetValue(data, "Player.Stats.Level")) -- nil
```

### `Path.SetValue(source, path, value)`

Writes a nested value. Missing intermediate tables are created automatically,
and existing non-table intermediate values are replaced with tables.

```lua
local data = {}

Path.SetValue(data, "Player.Stats.Coins", 250)

print(data.Player.Stats.Coins) -- 250
```

### `Path.SplitPath(path)`

Splits a dot-separated path into an array of keys.

```lua
local parts = Path.SplitPath("Player.Stats.Coins")

print(parts[1]) -- Player
print(parts[2]) -- Stats
print(parts[3]) -- Coins
```

### `Path.GetLastPathValue(path)`

Returns the final key in a dot-separated path, or `nil` when the path contains
no keys.

```lua
print(Path.GetLastPathValue("Player.Stats.Coins")) -- Coins
print(Path.GetLastPathValue("")) -- nil
```

## Path Rules

- Periods separate keys.
- Empty segments are ignored, so `"Player..Coins"` is treated as
  `"Player.Coins"`.
- Keys containing periods cannot be addressed.

## API

| Function | Returns | Description |
| --- | --- | --- |
| `Path.GetValue(source, path)` | `any` | Reads a nested value, returning `nil` when it cannot be found. |
| `Path.SetValue(source, path, value)` | `()` | Writes a nested value and creates missing intermediate tables. |
| `Path.SplitPath(path)` | `{ string }` | Splits a dot-separated path into keys. |
| `Path.GetLastPathValue(path)` | `string?` | Returns the final key in a path. |
