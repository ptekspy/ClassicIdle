# Migrate World-Space UI

## Goal

Replace all gameplay `BillboardGui` and `SurfaceGui` descendants with server-mounted React components. Preserve visibility to nearby players and preserve server-owned respawn timing.

## Files changed

Create:

```txt
src/ReplicatedStorage/Services/WorldUIService/init.luau
```

Replace:

```txt
src/ReplicatedStorage/UI/World/WorldLabel.luau
src/ReplicatedStorage/UI/World/SellBillboard.luau
src/ReplicatedStorage/UI/World/SellSurfaceDisplay.luau
src/ReplicatedStorage/UI/World/RespawnProgress.luau
src/ReplicatedStorage/Services/DisplayService/init.luau
```

Edit:

```txt
src/ReplicatedStorage/Services/ResourceNodeService/init.luau
src/ReplicatedStorage/Services/PlotService/init.luau
src/ReplicatedStorage/Plot/Config.luau
src/ReplicatedStorage/Plot/Types.luau
src/ReplicatedStorage/Plot/validate.luau
```

## 1. Create `WorldUIService`

Create `src/ReplicatedStorage/Services/WorldUIService/init.luau`:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReactRoblox = require(ReplicatedStorage.Vendor.ReactRoblox)

local roots: { [Instance]: any } = {}
local WorldUIService = {}

function WorldUIService.Render(host: Instance, element: any)
	local root = roots[host]
	if not root then
		root = ReactRoblox.createRoot(host)
		roots[host] = root
	end
	root:render(element)
end

function WorldUIService.Unmount(host: Instance)
	local root = roots[host]
	roots[host] = nil
	if root then
		root:unmount()
	end
end

function WorldUIService.UnmountTree(ancestor: Instance)
	local hosts = {}
	for host in roots do
		if host == ancestor or host:IsDescendantOf(ancestor) then
			table.insert(hosts, host)
		end
	end
	for _, host in hosts do
		WorldUIService.Unmount(host)
	end
end

return WorldUIService
```

## 2. Create `WorldLabel`

Replace `src/ReplicatedStorage/UI/World/WorldLabel.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function WorldLabel(props: { text: string })
	return React.createElement("TextLabel", {
		Name = "Label",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.2,
		Text = props.text,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextWrapped = true,
		Font = Enum.Font.GothamBold,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})
end

return WorldLabel
```

## 3. Create sell-display components

Replace `src/ReplicatedStorage/UI/World/SellBillboard.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function SellBillboard(props: { value: number })
	return React.createElement("TextLabel", {
		Name = "TextLabel",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		RichText = true,
		Text = `<stroke color="rgb(0, 118, 0)" joins="miter" thickness="7" transparency="0.5">${props.value}</stroke>`,
		TextColor3 = Color3.fromRGB(85, 255, 0),
		TextScaled = true,
		TextStrokeColor3 = Color3.fromRGB(0, 138, 0),
		TextStrokeTransparency = 0,
		TextWrapped = true,
	})
end

return SellBillboard
```

Replace `src/ReplicatedStorage/UI/World/SellSurfaceDisplay.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function SellSurfaceDisplay(props: { value: number })
	return React.createElement("TextLabel", {
		Name = "TextLabel",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = `${props.value}`,
		TextColor3 = Color3.fromRGB(0, 255, 0),
		TextScaled = true,
		TextWrapped = true,
	}, {
		SizeConstraint = React.createElement("UITextSizeConstraint", {
			MinTextSize = 1,
			MaxTextSize = 60,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Color3.fromRGB(0, 116, 0),
			Thickness = 5,
			LineJoinMode = Enum.LineJoinMode.Round,
			Transparency = 0,
		}),
	})
end

return SellSurfaceDisplay
```

## 4. Create `RespawnProgress`

Replace `src/ReplicatedStorage/UI/World/RespawnProgress.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function RespawnProgress(props: { progress: number })
	return React.createElement("Frame", {
		Name = "Background",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		Fill = React.createElement("Frame", {
			Name = "Fill",
			Size = UDim2.fromScale(math.clamp(props.progress, 0, 1), 1),
			BackgroundColor3 = Color3.fromRGB(95, 220, 110),
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

return RespawnProgress
```

## 5. Add the sell-screen part path

In `src/ReplicatedStorage/Plot/Types.luau`, replace:

```luau
	SellBillboard: string,
	SellBillboardLabel: string,
	SellScreenLabel: string,
```

with:

```luau
	SellScreen: string,
```

In `src/ReplicatedStorage/Plot/Config.luau`, replace:

```luau
		SellBillboard = "OLD.SellCrate.BillboardGui",
		SellBillboardLabel = "OLD.SellCrate.BillboardGui.TextLabel",
		SellScreenLabel = "OLD.SellCrate.Screen.SurfaceGui.TextLabel",
```

with:

```luau
		SellScreen = "OLD.SellCrate.Screen",
```

In `src/ReplicatedStorage/Plot/validate.luau`:

1. Delete the `getBillboardGui` and `getTextLabel` requires.
2. Add `paths.SellScreen` to the first list of required part paths.
3. Delete the final three validation calls for sell GUI/labels.

## 6. Replace `DisplayService`

Replace `src/ReplicatedStorage/Services/DisplayService/init.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local PlayerDataReplicaService = require(script.Parent.PlayerDataReplicaService)
local PlotConfig = require(ReplicatedStorage.Plot.Config)
local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local SellBillboard = require(ReplicatedStorage.UI.World.SellBillboard)
local SellSurfaceDisplay = require(ReplicatedStorage.UI.World.SellSurfaceDisplay)
local WorldLabel = require(ReplicatedStorage.UI.World.WorldLabel)
local WorldUIService = require(script.Parent.WorldUIService)
local getPlotPart = require(ReplicatedStorage.Plot.getPart)

local DisplayService = {}

local function getBillboard(part: BasePart, name: string, size: UDim2, offset: Vector3): BillboardGui
	local existing = part:FindFirstChild(name)
	if existing and existing:IsA("BillboardGui") then
		return existing
	end

	local gui = Instance.new("BillboardGui")
	gui.Name = name
	gui.Size = size
	gui.StudsOffset = offset
	gui.AlwaysOnTop = false
	gui.MaxDistance = 35
	gui.Parent = part
	return gui
end

local function renderWorldLabel(part: BasePart, name: string, size: UDim2, offset: Vector3, text: string)
	local gui = getBillboard(part, name, size, offset)
	WorldUIService.Render(gui, React.createElement(WorldLabel, {
		text = text,
	}))
end

function DisplayService.SetupLeaderstats(player: Player)
	local data = DataService.Get(player)
	local existing = player:FindFirstChild("leaderstats")
	if existing then
		existing:Destroy()
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local gold = Instance.new("NumberValue")
	gold.Name = "Gold"
	gold.Value = data.Gold
	gold.Parent = leaderstats

	for _, resourceId in ResourceConfig.Order do
		local definition = ResourceConfig.Get(resourceId)
		if definition and definition.ShowInLeaderstats then
			local value = Instance.new("NumberValue")
			value.Name = resourceId
			value.Value = EconomyService.GetResourceAmount(data, resourceId)
			value.Parent = leaderstats
		end
	end

	local xp = Instance.new("IntValue")
	xp.Name = "XP"
	xp.Value = data.XP
	xp.Parent = leaderstats
end

function DisplayService.UpdateLeaderstats(player: Player)
	local data = DataService.Get(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	local gold = leaderstats:FindFirstChild("Gold")
	local xp = leaderstats:FindFirstChild("XP")
	if gold and gold:IsA("NumberValue") then
		gold.Value = data.Gold
	end
	for _, resourceId in ResourceConfig.Order do
		local value = leaderstats:FindFirstChild(resourceId)
		if value and (value:IsA("IntValue") or value:IsA("NumberValue")) then
			value.Value = EconomyService.GetResourceAmount(data, resourceId)
		end
	end
	if xp and xp:IsA("IntValue") then
		xp.Value = data.XP
	end

	PlayerDataReplicaService.Sync(player)
end

function DisplayService.UpdateStorageDisplay(player: Player, plot: Model)
	local data = DataService.Get(player)
	local lines = { `Storage {EconomyService.GetUsedStorage(data)}/{EconomyService.GetStorageCapacity(data)}` }
	for _, resourceId in ResourceConfig.Order do
		local definition = ResourceConfig.Get(resourceId)
		if definition then
			table.insert(lines, `{definition.DisplayName}: {EconomyService.GetResourceAmount(data, resourceId)}`)
		end
	end
	renderWorldLabel(
		getPlotPart(plot, PlotConfig.Paths.StorageDisplayAnchor),
		"StorageDisplay",
		UDim2.fromOffset(170, 85),
		Vector3.new(0, 3.5, 0),
		table.concat(lines, "\n")
	)
end

function DisplayService.UpdateMachineDisplays(player: Player, plot: Model)
	local data = DataService.Get(player)
	renderWorldLabel(
		getPlotPart(plot, PlotConfig.Paths.NPCPurchasePad),
		"NPCDisplay",
		UDim2.fromOffset(190, 75),
		Vector3.new(0, 3.5, 0),
		`Hire NPCs\nOwned: {EconomyService.GetNPCCount(data)}`
	)
end

function DisplayService.UpdateUpgradeButtonDisplays(player: Player, plot: Model)
	local data = DataService.Get(player)
	renderWorldLabel(
		getPlotPart(plot, PlotConfig.Paths.StorageUpgradeButton),
		"UpgradeDisplay",
		UDim2.fromOffset(175, 75),
		Vector3.new(0, 3.5, 0),
		`Upgrade Storage\nCapacity: {EconomyService.GetStorageCapacity(data)}\nCost: {EconomyService.GetStorageUpgradeCost(data)} Gold`
	)
end

function DisplayService.UpdateSellDisplay(player: Player, plot: Model)
	local value = EconomyService.GetTotalSellValue(DataService.Get(player))
	local touchPad = getPlotPart(plot, PlotConfig.Paths.SellTouchPad)
	local screenPart = getPlotPart(plot, PlotConfig.Paths.SellScreen)

	local billboard = getBillboard(touchPad, "SellBillboard", UDim2.fromScale(3, 3), Vector3.zero)
	billboard.Adornee = touchPad
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 50
	billboard.SizeOffset = Vector2.new(0, 2)
	WorldUIService.Render(billboard, React.createElement(SellBillboard, { value = value }))

	local surface = screenPart:FindFirstChild("SellSurfaceDisplay")
	if not surface or not surface:IsA("SurfaceGui") then
		surface = Instance.new("SurfaceGui")
		surface.Name = "SellSurfaceDisplay"
		surface.Face = Enum.NormalId.Right
		surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surface.PixelsPerStud = 50
		surface.Parent = screenPart
	end
	WorldUIService.Render(surface, React.createElement(SellSurfaceDisplay, { value = value }))
end

function DisplayService.UpdateAll(player: Player, plot: Model)
	DisplayService.UpdateLeaderstats(player)
	DisplayService.UpdateStorageDisplay(player, plot)
	DisplayService.UpdateMachineDisplays(player, plot)
	DisplayService.UpdateUpgradeButtonDisplays(player, plot)
	DisplayService.UpdateSellDisplay(player, plot)
end

return DisplayService
```

## 7. Unmount plot roots before destroying plots

In `src/ReplicatedStorage/Services/PlotService/init.luau`, add:

```luau
local WorldUIService = require(ReplicatedStorage.Services.WorldUIService)
```

Replace:

```luau
	if plot then
		plot:Destroy()
	end
```

with:

```luau
	if plot then
		WorldUIService.UnmountTree(plot)
		plot:Destroy()
	end
```

## 8. Migrate resource respawn progress

In `src/ReplicatedStorage/Services/ResourceNodeService/init.luau`, add:

```luau
local React = require(ReplicatedStorage.Vendor.React)
local RespawnProgress = require(ReplicatedStorage.UI.World.RespawnProgress)
local WorldUIService = require(ReplicatedStorage.Services.WorldUIService)
```

Replace the entire `createProgressGui` function with:

```luau
local function createProgressGui(node: Model): BillboardGui
	local primaryPart = node.PrimaryPart
	if not primaryPart then
		error(`Resource node {node:GetFullName()} must have a PrimaryPart`)
	end

	local existing = primaryPart:FindFirstChild("RespawnProgress")
	if existing and existing:IsA("BillboardGui") then
		return existing
	end

	local gui = Instance.new("BillboardGui")
	gui.Name = "RespawnProgress"
	gui.Size = UDim2.fromOffset(160, 26)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Enabled = false
	gui.Parent = primaryPart

	WorldUIService.Render(gui, React.createElement(RespawnProgress, {
		progress = 0,
	}))
	return gui
end
```

In `beginRespawn`, delete:

```luau
	local background = gui:FindFirstChild("Background") :: Frame
	local fill = background:FindFirstChild("Fill") :: Frame
```

Replace:

```luau
	fill.Size = UDim2.fromScale(0, 1)
```

with:

```luau
	WorldUIService.Render(gui, React.createElement(RespawnProgress, { progress = 0 }))
```

Inside the heartbeat loop, replace the `fill.Size` assignment with:

```luau
			WorldUIService.Render(gui, React.createElement(RespawnProgress, {
				progress = math.clamp((os.clock() - startedAt) / duration, 0, 1),
			}))
```

Replace:

```luau
	fill.Size = UDim2.fromScale(1, 1)
```

with:

```luau
	WorldUIService.Render(gui, React.createElement(RespawnProgress, { progress = 1 }))
```

Do not move respawn timing into React.

## 9. Delete physical Studio UI

Before the first parity test, temporarily set `Enabled = false` on:

```txt
ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.BillboardGui
ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.Screen.SurfaceGui
```

This prevents the physical and programmatic versions appearing on top of each other.

After the programmatic versions pass validation, manually delete:

```txt
ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.BillboardGui
ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.Screen.SurfaceGui
```

Do not delete `SellCrate`, `SellCrate.TouchPad`, or `SellCrate.Screen`.

## Validation

- Start a two-player server and view both plots from both clients.
- Confirm storage, hire, upgrade, and sell displays are visible to nearby players.
- Sell resources and confirm billboard and surface values update.
- Upgrade storage and hire NPCs; confirm their world labels update.
- Deplete a resource node; confirm the progress bar fills and hides.
- Leave/rejoin and confirm plot roots unmount without errors.
- Delete the two physical UI objects and confirm the game still starts.
- Confirm `Plot.validate` reports no missing UI objects.

## Done when

Every gameplay world-space UI is created from React code and no physical Studio UI is required.
