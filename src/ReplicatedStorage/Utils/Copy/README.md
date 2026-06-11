# Copy

Utilities for copying table data.

## Usage

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Copy = require(ReplicatedStorage.Packages.Utils.Copy)
```

### `Copy.CopyData(data, blacklist?)`

Creates a shallow copy of `data`. An optional blacklist can exclude top-level
keys by setting their values to `true`.

```lua
local original = {
	Name = "Player",
	Coins = 125,
	InternalId = "abc-123",
}

local copied = Copy.CopyData(original, {
	InternalId = true,
})

print(copied.Name) -- Player
print(copied.Coins) -- 125
print(copied.InternalId) -- nil
```

The returned table is new, but nested tables and other values retain their
original references:

```lua
local original = {
	Stats = {
		Coins = 125,
	},
}

local copied = Copy.CopyData(original)

print(copied ~= original) -- true
print(copied.Stats == original.Stats) -- true
```

Blacklist entries only exclude a key when their value is exactly `true`.

## API

| Function | Returns | Description |
| --- | --- | --- |
| `Copy.CopyData(data, blacklist?)` | `{}` | Creates a shallow copy, optionally excluding blacklisted top-level keys. |
