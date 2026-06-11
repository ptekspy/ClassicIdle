--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local menuEvent = RemoteManager.WorkerMenu :: RemoteEvent
local requestEvent = RemoteManager.WorkerRequest :: RemoteEvent

local WorkerController = {}

local gui = Instance.new("ScreenGui")
gui.Name = "WorkerGui"
gui.DisplayOrder = 30
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = playerGui

local shade = Instance.new("Frame")
shade.Name = "Shade"
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.new(0, 0, 0)
shade.BackgroundTransparency = 0.45
shade.Visible = false
shade.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.85, 0, 0, 390)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.Parent = shade

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(300, 390)
sizeConstraint.MaxSize = Vector2.new(520, 390)
sizeConstraint.Parent = panel

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(20, 14)
title.Size = UDim2.new(1, -80, 0, 42)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 25
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local close = Instance.new("TextButton")
close.Name = "Close"
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -14, 0, 14)
close.Size = UDim2.fromOffset(42, 42)
close.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
close.Font = Enum.Font.GothamBold
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 18
close.Parent = panel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = close

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.fromOffset(20, 68)
content.Size = UDim2.new(1, -40, 1, -88)
content.BackgroundTransparency = 1
content.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = content

local function clearContent()
	for _, child in content:GetChildren() do
		if child ~= layout then
			child:Destroy()
		end
	end
end

local function addLabel(text: string, height: number?)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, height or 46)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = 18
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = content
end

local function addButton(text: string, enabled: boolean, callback: () -> ())
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 64)
	button.BackgroundColor3 = if enabled then Color3.fromRGB(65, 130, 80) else Color3.fromRGB(65, 65, 65)
	button.AutoButtonColor = enabled
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 18
	button.TextWrapped = true
	button.Parent = content

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = button

	if enabled then
		button.Activated:Connect(callback)
	end
end

local function showMenu(payload: any)
	if typeof(payload) ~= "table" or typeof(payload.Kind) ~= "string" then
		return
	end

	clearContent()
	shade.Visible = true

	if payload.Kind == "Purchase" then
		title.Text = "Hire NPC"

		for _, role in payload.Roles do
			local enabled = role.Unlocked == true
			local text = if enabled
				then `{role.DisplayName}\nCost: {role.Cost} Gold`
				else `{role.DisplayName}\nLocked`
			addButton(text, enabled, function()
				requestEvent:FireServer("Buy", role.Role)
			end)
		end
	elseif payload.Kind == "Manage" then
		title.Text = payload.DisplayName
		local cargo = if payload.CargoAmount > 0 then `{payload.CargoAmount} {payload.CargoType}` else "Empty"
		addLabel(`Current cargo: {cargo}`)
		addButton(`Upgrade Speed\n{payload.Speed} → {payload.Speed + 2} • {payload.SpeedCost} Gold`, true, function()
			requestEvent:FireServer("Upgrade", payload.NPCId, "Speed")
		end)
		addButton(`Upgrade Amount\n{payload.Amount} → {payload.Amount + 1} • {payload.AmountCost} Gold`, true, function()
			requestEvent:FireServer("Upgrade", payload.NPCId, "Amount")
		end)
	end
end

function WorkerController.Start()
	close.Activated:Connect(function()
		shade.Visible = false
	end)
	menuEvent.OnClientEvent:Connect(showMenu)
end

return WorkerController
