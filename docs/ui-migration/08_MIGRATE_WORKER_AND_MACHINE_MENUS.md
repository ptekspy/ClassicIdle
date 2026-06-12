# Migrate Worker And Machine Menus

## Goal

Replace `WorkerGui` and `MachineGui` with React screens. Controllers continue to own remotes and publish menu payloads/callbacks to `UIState`.

## Files changed

Replace:

```txt
src/ReplicatedStorage/UI/Components/ActionButton.luau
src/ReplicatedStorage/UI/Components/ModalPanel.luau
src/ReplicatedStorage/UI/Components/WorkerMenuContent.luau
src/ReplicatedStorage/UI/Components/MachineMenuContent.luau
src/ReplicatedStorage/UI/Screens/WorkerScreen.luau
src/ReplicatedStorage/UI/Screens/MachineScreen.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/WorkerController.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/MachineController.luau
```

Edit:

```txt
src/ReplicatedStorage/UI/Screens/App.luau
src/StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.luau
```

## 1. Create `ActionButton`

Replace `src/ReplicatedStorage/UI/Components/ActionButton.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	text: string,
	enabled: boolean?,
	height: number?,
	textSize: number?,
	layoutOrder: number?,
	onActivated: () -> (),
}

local function ActionButton(props: Props)
	local enabled = props.enabled ~= false

	return React.createElement("TextButton", {
		Size = UDim2.new(1, 0, 0, props.height or 64),
		LayoutOrder = props.layoutOrder or 0,
		BackgroundColor3 = if enabled then Color3.fromRGB(65, 130, 80) else Color3.fromRGB(65, 65, 65),
		AutoButtonColor = enabled,
		Font = Enum.Font.GothamBold,
		Text = props.text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = props.textSize or 18,
		TextWrapped = true,
		Active = enabled,
		[React.Event.Activated] = if enabled then props.onActivated else nil,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
	})
end

return ActionButton
```

## 2. Create `ModalPanel`

Replace `src/ReplicatedStorage/UI/Components/ModalPanel.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	title: string,
	visible: boolean,
	onClose: () -> (),
	children: React.ReactNode,
}

local function ModalPanel(props: Props)
	return React.createElement("Frame", {
		Name = "Shade",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		Visible = props.visible,
	}, {
		Panel = React.createElement("Frame", {
			Name = "Panel",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.85, 0, 0, 390),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		}, {
			Constraint = React.createElement("UISizeConstraint", {
				MinSize = Vector2.new(300, 390),
				MaxSize = Vector2.new(520, 390),
			}),
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 14),
			}),
			Title = React.createElement("TextLabel", {
				Position = UDim2.fromOffset(20, 14),
				Size = UDim2.new(1, -80, 0, 42),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Text = props.title,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 25,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			Close = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -14, 0, 14),
				Size = UDim2.fromOffset(42, 42),
				BackgroundColor3 = Color3.fromRGB(55, 55, 55),
				Font = Enum.Font.GothamBold,
				Text = "X",
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 18,
				[React.Event.Activated] = props.onClose,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 10),
				}),
			}),
			Content = React.createElement("Frame", {
				Position = UDim2.fromOffset(20, 68),
				Size = UDim2.new(1, -40, 1, -88),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					Padding = UDim.new(0, 10),
				}),
				Body = React.createElement(React.Fragment, nil, props.children),
			}),
		}),
	})
end

return ModalPanel
```

## 3. Create `WorkerMenuContent`

Replace `src/ReplicatedStorage/UI/Components/WorkerMenuContent.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local ActionButton = require(script.Parent.ActionButton)

local function WorkerMenuContent(props: { menu: any })
	local menu = props.menu
	local payload = menu.payload
	local children = {}

	if payload.Kind == "Purchase" then
		for index, role in payload.Roles do
			local enabled = role.Unlocked == true
			children[`Role{index}`] = React.createElement(ActionButton, {
				text = if enabled then `{role.DisplayName}\nCost: {role.Cost} Gold` else `{role.DisplayName}\nLocked`,
				enabled = enabled,
				layoutOrder = index,
				onActivated = function()
					menu.onBuy(role.Role)
				end,
			})
		end
	elseif payload.Kind == "Manage" then
		local cargo = if payload.CargoAmount > 0 then `{payload.CargoAmount} {payload.CargoType}` else "Empty"
		children.Cargo = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 46),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = `Current cargo: {cargo}`,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 18,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		children.Speed = React.createElement(ActionButton, {
			text = `Upgrade Speed\n{payload.Speed} → {payload.Speed + 2} • {payload.SpeedCost} Gold`,
			layoutOrder = 2,
			onActivated = function()
				menu.onUpgrade(payload.NPCId, "Speed")
			end,
		})
		children.Amount = React.createElement(ActionButton, {
			text = `Upgrade Amount\n{payload.Amount} → {payload.Amount + 1} • {payload.AmountCost} Gold`,
			layoutOrder = 3,
			onActivated = function()
				menu.onUpgrade(payload.NPCId, "Amount")
			end,
		})
	end

	return React.createElement(React.Fragment, nil, children)
end

return WorkerMenuContent
```

## 4. Create `MachineMenuContent`

Replace `src/ReplicatedStorage/UI/Components/MachineMenuContent.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local ActionButton = require(script.Parent.ActionButton)

local function MachineMenuContent(props: { menu: any })
	local menu = props.menu
	local payload = menu.payload
	local children = {}

	if payload.Kind == "Processor" then
		children.Processing = React.createElement(ActionButton, {
			height = 72,
			layoutOrder = 1,
			text = `Upgrade Processing Time\n{payload.ProcessingTime}s -> {payload.NextProcessingTime}s | {payload.ProcessingTimeCost} Gold`,
			onActivated = function()
				menu.onUpgrade(payload.PartId, "ProcessingTime")
			end,
		})
		children.Multiplier = React.createElement(ActionButton, {
			height = 72,
			layoutOrder = 2,
			text = `Upgrade Output Multiplier\nx{payload.OutputMultiplier} -> x{payload.NextOutputMultiplier} | {payload.OutputMultiplierCost} Gold`,
			onActivated = function()
				menu.onUpgrade(payload.PartId, "OutputMultiplier")
			end,
		})
	elseif payload.Upgradeable then
		if payload.PartId == "CollectionPoint" then
			children.Collect = React.createElement(ActionButton, {
				height = 72,
				layoutOrder = 1,
				text = "Collect Stored Coal",
				onActivated = function()
					menu.onCollect(payload.PartId)
				end,
			})
		end
		children.Upgrade = React.createElement(ActionButton, {
			height = 72,
			layoutOrder = 2,
			text = `Upgrade {payload.StatName}\n{payload.CurrentValue} -> {payload.NextValue} | {payload.UpgradeCost} Gold`,
			onActivated = function()
				menu.onUpgrade(payload.PartId, "Level")
			end,
		})
	end

	return React.createElement(React.Fragment, nil, children)
end

return MachineMenuContent
```

## 5. Create both screens

Replace `src/ReplicatedStorage/UI/Screens/WorkerScreen.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local ModalPanel = require(script.Parent.Parent.Components.ModalPanel)
local WorkerMenuContent = require(script.Parent.Parent.Components.WorkerMenuContent)

local function WorkerScreen(props: { menu: any? })
	local menu = props.menu
	local title = if menu and menu.payload.Kind == "Purchase" then "Hire NPC" else if menu then menu.payload.DisplayName else ""

	return React.createElement("ScreenGui", {
		Name = "WorkerGui",
		DisplayOrder = 30,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Modal = React.createElement(ModalPanel, {
			title = title,
			visible = menu ~= nil,
			onClose = if menu then menu.onClose else function() end,
		}, if menu then {
			Content = React.createElement(WorkerMenuContent, { menu = menu }),
		} else nil),
	})
end

return WorkerScreen
```

Replace `src/ReplicatedStorage/UI/Screens/MachineScreen.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local MachineMenuContent = require(script.Parent.Parent.Components.MachineMenuContent)
local ModalPanel = require(script.Parent.Parent.Components.ModalPanel)

local function MachineScreen(props: { menu: any? })
	local menu = props.menu

	return React.createElement("ScreenGui", {
		Name = "MachineGui",
		DisplayOrder = 30,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Modal = React.createElement(ModalPanel, {
			title = if menu then menu.payload.DisplayName else "",
			visible = menu ~= nil,
			onClose = if menu then menu.onClose else function() end,
		}, if menu then {
			Content = React.createElement(MachineMenuContent, { menu = menu }),
		} else nil),
	})
end

return MachineScreen
```

## 6. Replace `WorkerController`

Replace the entire file with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)
local UIState = require(script.Parent.Parent.UI.UIState)

local menuEvent = RemoteManager.WorkerMenu :: RemoteEvent
local requestEvent = RemoteManager.WorkerRequest :: RemoteEvent
local started = false

local WorkerController = {}

local function close()
	UIState.Set("workerMenu", nil)
end

local function showMenu(payload: any)
	if typeof(payload) ~= "table" or typeof(payload.Kind) ~= "string" then
		return
	end

	UIState.Set("workerMenu", {
		payload = payload,
		onClose = close,
		onBuy = function(role: string)
			requestEvent:FireServer("Buy", role)
		end,
		onUpgrade = function(npcId: string, upgradeType: string)
			requestEvent:FireServer("Upgrade", npcId, upgradeType)
		end,
	})
end

function WorkerController.Start()
	if started then
		return
	end
	started = true
	menuEvent.OnClientEvent:Connect(showMenu)
end

return WorkerController
```

## 7. Replace `MachineController`

Replace the entire file with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)
local UIState = require(script.Parent.Parent.UI.UIState)

local menuEvent = RemoteManager.MachineMenu :: RemoteEvent
local requestEvent = RemoteManager.MachineRequest :: RemoteEvent
local started = false

local MachineController = {}

local function close()
	UIState.Set("machineMenu", nil)
end

local function show(payload: any)
	if typeof(payload) ~= "table" or typeof(payload.PartId) ~= "string" then
		return
	end

	UIState.Set("machineMenu", {
		payload = payload,
		onClose = close,
		onCollect = function(partId: string)
			requestEvent:FireServer("Collect", partId)
		end,
		onUpgrade = function(partId: string, upgradeType: string)
			requestEvent:FireServer("Upgrade", partId, upgradeType)
		end,
	})
end

function MachineController.Start()
	if started then
		return
	end
	started = true
	menuEvent.OnClientEvent:Connect(show)
end

return MachineController
```

## 8. Start `MachineController`

In `ClientBootstrap.client.luau`, add:

```luau
local MachineController = require(script.Parent.Controllers.MachineController)
```

Add:

```luau
MachineController.Start()
```

beside the other controller starts.

## 9. Add both screens to `App`

Add requires:

```luau
local MachineScreen = require(script.Parent.MachineScreen)
local WorkerScreen = require(script.Parent.WorkerScreen)
```

Inside the provider children, add:

```luau
Worker = React.createElement(WorkerScreen, {
	menu = props.state.workerMenu,
}),
Machine = React.createElement(MachineScreen, {
	menu = props.state.machineMenu,
}),
```

## Validation

- Confirm there is one React-owned `WorkerGui` and one React-owned `MachineGui`.
- Hire every unlocked worker role.
- Confirm locked roles cannot fire requests.
- Upgrade worker speed and amount.
- Open each machine type and run every available action.
- Close each menu and confirm its shade disappears.
- Confirm machine menus now appear because `MachineController.Start()` is called.

## Done when

Both modal menu systems are React-owned and all actions still pass through existing remotes.
