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
local characterConnection: RBXScriptConnection? = nil

local function render(state: any)
	root:render(React.createElement(App, {
		state = state,
	}))
end

local function mount()
	if root then
		root:unmount()
		root = nil
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local host = playerGui:FindFirstChild("ReactUI")
	if not host then
		host = Instance.new("Folder")
		host.Name = "ReactUI"
		host.Parent = playerGui
	end

	root = ReactRoblox.createRoot(host)
	render(UIState.Get())
end

function UIRoot.Start()
	if root then
		return
	end

	mount()
	stateConnection = UIState.Subscribe(function()
		render(UIState.Get())
	end)
	characterConnection = Players.LocalPlayer.CharacterAdded:Connect(function()
		task.defer(function()
			local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
			if playerGui and not playerGui:FindFirstChild("ReactUI") then
				mount()
			end
		end)
	end)
end

function UIRoot.Stop()
	if stateConnection then
		stateConnection:Disconnect()
		stateConnection = nil
	end
	if characterConnection then
		characterConnection:Disconnect()
		characterConnection = nil
	end
	if root then
		root:unmount()
		root = nil
	end
end

return UIRoot
