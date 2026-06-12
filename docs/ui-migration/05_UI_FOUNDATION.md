# UI Foundation

## Goal

Mount one React root and provide a small transient-state bridge for existing controllers.

## Create `UIState`

Create `src/StarterPlayer/StarterPlayerScripts/UI/UIState.luau`:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local changed = Signal.New()
local state = {
	feedback = nil,
	quest = nil,
	interaction = nil,
	workerMenu = nil,
	machineMenu = nil,
	factory = nil,
}

local UIState = {}

function UIState.Get(): any
	return state
end

function UIState.Set(key: string, value: any)
	state = table.clone(state)
	state[key] = value
	changed:Fire(state)
end

function UIState.Subscribe(callback: (any) -> ()): any
	return changed:Connect(callback)
end

return UIState
```

## Create the app

Create `src/ReplicatedStorage/UI/Screens/App.luau`:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local PlayerDataContext = require(script.Parent.Parent.Context.PlayerDataContext)

local function App(props: { state: any })
	return React.createElement(PlayerDataContext.Provider, nil, {
		-- Add migrated screens here one stage at a time and pass props.state fields.
	})
end

return App
```

## Create and mount the root

Create `src/StarterPlayer/StarterPlayerScripts/UI/UIRoot.luau`:

```luau
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local ReactRoblox = require(ReplicatedStorage.Vendor.ReactRoblox)
local App = require(ReplicatedStorage.UI.Screens.App)
local UIState = require(script.Parent.UIState)

local UIRoot = {}
local root: any = nil
local stateConnection: any = nil

function UIRoot.Start()
	if root then
		return
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local host = playerGui:FindFirstChild("ReactUI")
	if not host then
		host = Instance.new("Folder")
		host.Name = "ReactUI"
		host.Parent = playerGui
	end

	root = ReactRoblox.createRoot(host)
	local function render(state: any)
		root:render(React.createElement(App, {
			state = state,
		}))
	end

	render(UIState.Get())
	stateConnection = UIState.Subscribe(function()
		render(UIState.Get())
	end)
end

function UIRoot.Stop()
	if stateConnection then
		stateConnection:Disconnect()
		stateConnection = nil
	end
	if root then
		root:unmount()
		root = nil
	end
end

return UIRoot
```

Edit `ClientBootstrap.client.luau`:

```luau
local UIRoot = require(script.Parent.UI.UIRoot)
UIRoot.Start()
```

## Rules

- `ResetOnSpawn = false` remains on every React-created `ScreenGui`.
- Do not mount one root per screen.
- Do not parent React-owned descendants from imperative code.
- Existing controllers may remain active until their specific migration stage.
- Controllers require the bridge with `require(script.Parent.Parent.UI.UIState)`.

## Validation

- Start Play mode and confirm `PlayerGui.ReactUI` appears once.
- Reset character three times and confirm it still appears once.
- Confirm no visual difference yet.

## Done when

One root mounts once, survives reset, and unmounts cleanly.
