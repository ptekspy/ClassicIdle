--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local menuEvent = RemoteManager.MachineMenu :: RemoteEvent
local requestEvent = RemoteManager.MachineRequest :: RemoteEvent

local MachineController = {}

local gui = Instance.new("ScreenGui")
gui.Name = "MachineGui"
gui.DisplayOrder = 30
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = playerGui

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.new(0, 0, 0)
shade.BackgroundTransparency = 0.45
shade.Visible = false
shade.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.85, 0, 0, 390)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.Parent = shade

local constraint = Instance.new("UISizeConstraint")
constraint.MinSize = Vector2.new(300, 390)
constraint.MaxSize = Vector2.new(520, 390)
constraint.Parent = panel

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(20, 14)
title.Size = UDim2.new(1, -80, 0, 42)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 25
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -14, 0, 14)
close.Size = UDim2.fromOffset(42, 42)
close.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
close.Font = Enum.Font.GothamBold
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 18
close.Parent = panel

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(20, 68)
content.Size = UDim2.new(1, -40, 1, -88)
content.BackgroundTransparency = 1
content.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = content

local function clear()
	for _, child in content:GetChildren() do
		if child ~= layout then
			child:Destroy()
		end
	end
end

local function button(text: string, callback: () -> ())
	local item = Instance.new("TextButton")
	item.Size = UDim2.new(1, 0, 0, 72)
	item.BackgroundColor3 = Color3.fromRGB(65, 130, 80)
	item.Font = Enum.Font.GothamBold
	item.Text = text
	item.TextColor3 = Color3.new(1, 1, 1)
	item.TextSize = 18
	item.TextWrapped = true
	item.Parent = content
	local itemCorner = Instance.new("UICorner")
	itemCorner.CornerRadius = UDim.new(0, 10)
	itemCorner.Parent = item
	item.Activated:Connect(callback)
end

local function show(payload: any)
	if typeof(payload) ~= "table" or typeof(payload.PartId) ~= "string" then
		return
	end
	clear()
	shade.Visible = true
	title.Text = payload.DisplayName

	if payload.Kind == "Processor" then
		button(
			`Upgrade Processing Time\n{payload.ProcessingTime}s -> {payload.NextProcessingTime}s | {payload.ProcessingTimeCost} Gold`,
			function()
				requestEvent:FireServer("Upgrade", payload.PartId, "ProcessingTime")
			end
		)
		button(
			`Upgrade Output Multiplier\nx{payload.OutputMultiplier} -> x{payload.NextOutputMultiplier} | {payload.OutputMultiplierCost} Gold`,
			function()
				requestEvent:FireServer("Upgrade", payload.PartId, "OutputMultiplier")
			end
		)
	elseif payload.Upgradeable then
		if payload.PartId == "CollectionPoint" then
			button(`Collect Stored Coal`, function()
				requestEvent:FireServer("Collect", payload.PartId)
			end)
		end
		button(
			`Upgrade {payload.StatName}\n{payload.CurrentValue} -> {payload.NextValue} | {payload.UpgradeCost} Gold`,
			function()
				requestEvent:FireServer("Upgrade", payload.PartId, "Level")
			end
		)
	end
end

function MachineController.Start()
	close.Activated:Connect(function()
		shade.Visible = false
	end)
	menuEvent.OnClientEvent:Connect(show)
end

return MachineController
