# Replica Player Data

## Goal

Create one owner-only player-data replica and expose its read-only snapshot through React context.

## 1. Create the server service

Create `src/ReplicatedStorage/Services/PlayerDataReplicaService/init.luau`:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local Replica = require(ReplicatedStorage.Packages.Replica.Server)

local PLAYER_DATA_TOKEN = Replica.Token("PlayerData")
local replicas = {} :: { [Player]: any }

local PlayerDataReplicaService = {}

local function deepCopy(value: any): any
	if typeof(value) ~= "table" then
		return value
	end

	local result = {}
	for key, child in value do
		result[deepCopy(key)] = deepCopy(child)
	end
	return result
end

local function snapshot(player: Player): any
	return deepCopy(DataService.Get(player))
end

function PlayerDataReplicaService.Create(player: Player)
	if replicas[player] then
		return
	end

	local replica = Replica.New({
		Token = PLAYER_DATA_TOKEN,
		Tags = { UserId = player.UserId },
		Data = snapshot(player),
	})

	replicas[player] = replica
	if Replica.ReadyPlayers[player] then
		replica:Subscribe(player)
	end
end

function PlayerDataReplicaService.Sync(player: Player)
	local replica = replicas[player]
	local data = DataService.TryGet(player)
	if not replica or not data then
		return
	end

	replica:SetValues({}, deepCopy(data))
end

function PlayerDataReplicaService.Destroy(player: Player)
	local replica = replicas[player]
	replicas[player] = nil
	if replica then
		replica:Destroy()
	end
end

Replica.NewReadyPlayer:Connect(function(player)
	local replica = replicas[player]
	if replica then
		replica:Subscribe(player)
	end
end)

return PlayerDataReplicaService
```

The deep copy is required. A shallow copy would share nested profile tables with `replica.Data`, allowing direct server mutations to change the replica silently without emitting an update.

The `NewReadyPlayer` connection is also required. `Replica:Subscribe(player)` ignores players until their client has called `Replica.RequestData()`.

## 2. Create, sync, and destroy replicas

Edit `src/ServerScriptService/ServerBootstrap.server.luau`.

Require the service:

```luau
local PlayerDataReplicaService = require(Services:WaitForChild("PlayerDataReplicaService"))
```

Immediately after a successful `DataService.Load(player)`:

```luau
PlayerDataReplicaService.Create(player)
```

Before `DataService.Release(player)` in every failure/removal path:

```luau
PlayerDataReplicaService.Destroy(player)
```

Edit `src/ReplicatedStorage/Services/DisplayService/init.luau`.

Require:

```luau
local PlayerDataReplicaService = require(script.Parent.PlayerDataReplicaService)
```

At the end of `DisplayService.UpdateLeaderstats(player)`:

```luau
PlayerDataReplicaService.Sync(player)
```

This captures existing mutation flows because current services call `UpdateAll` or `UpdateLeaderstats` after player-visible changes. During testing, search for authoritative mutations that do not reach either method and add an explicit `PlayerDataReplicaService.Sync(player)` after them.

## 3. Create React context

Create `src/ReplicatedStorage/UI/Context/PlayerDataContext.luau`:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local Replica = require(ReplicatedStorage.Packages.Replica.Client)

local PlayerDataContext = React.createContext(nil :: any)

local function copySnapshot(data: any): any
	return table.clone(data)
end

local function PlayerDataProvider(props: { children: any })
	local playerData, setPlayerData = React.useState(nil :: any)

	React.useEffect(function()
		local changeConnection: any = nil
		local newReplicaConnection = Replica.OnNew("PlayerData", function(replica)
			setPlayerData(copySnapshot(replica.Data))
			changeConnection = replica:OnChange(function()
				setPlayerData(copySnapshot(replica.Data))
			end)
		end)

		Replica.RequestData()

		return function()
			newReplicaConnection:Disconnect()
			if changeConnection then
				changeConnection:Disconnect()
			end
		end
	end, {})

	return React.createElement(PlayerDataContext.Provider, {
		value = playerData,
	}, props.children)
end

local function usePlayerData(): any
	return React.useContext(PlayerDataContext)
end

return {
	Provider = PlayerDataProvider,
	usePlayerData = usePlayerData,
}
```

## 4. Guardrails

- Call `Replica.RequestData()` once, inside the provider.
- Never put callbacks or menu state into the player-data replica.
- Never call Replica setters from the client.
- Continue to send purchases, upgrades, collecting, and placement through existing remotes.
- Treat a `nil` context value as loading state.

## Validation

- Join and inspect the client: exactly one `PlayerData` replica exists.
- Confirm its `Tags.UserId` matches the local player.
- Change gold/resources/storage/NPC/factory/quest data and confirm context consumers rerender.
- In a two-player test, confirm each client receives only its own replica.
- Reset character and confirm no second subscription is created.

## Done when

`usePlayerData()` returns current persistent player data and no UI component reads leaderstats directly.
