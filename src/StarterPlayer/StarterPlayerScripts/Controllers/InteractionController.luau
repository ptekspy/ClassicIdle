--!strict

local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local InteractionConfig = require(ReplicatedStorage.Interaction.Config)
local getClosestPoint = require(ReplicatedStorage.Interaction.getClosestPoint)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)

type InputMode = "MouseKeyboard" | "Gamepad" | "Touch"
type InteractionTarget = Model

local interactionEvent = RemoteManager.InteractionRequest :: RemoteEvent
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local plotSpawns = workspace:WaitForChild("PlotSpawns")

local Local = {
	FALLBACK_SCREEN_RADIUS = 220,
	inputMode = "MouseKeyboard" :: InputMode,
	focusedTarget = nil :: InteractionTarget?,
	started = false,
}

local InteractionController = {}

local gui = Instance.new("ScreenGui")
gui.Name = "InteractionGui"
gui.DisplayOrder = 20
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = playerGui

local highlight = Instance.new("Highlight")
highlight.Name = "InteractionHighlight"
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.FillTransparency = 1
highlight.OutlineColor = Color3.new(1, 1, 1)
highlight.OutlineTransparency = 0
highlight.Enabled = false
highlight.Parent = workspace

local prompt = Instance.new("Frame")
prompt.Name = "Prompt"
prompt.AnchorPoint = Vector2.new(0.5, 1)
prompt.Position = UDim2.fromScale(0.5, 0.92)
prompt.Size = UDim2.new(0.8, 0, 0, 82)
prompt.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
prompt.BackgroundTransparency = 0.12
prompt.Visible = false
prompt.Parent = gui

local promptSizeConstraint = Instance.new("UISizeConstraint")
promptSizeConstraint.MaxSize = Vector2.new(440, 82)
promptSizeConstraint.MinSize = Vector2.new(240, 82)
promptSizeConstraint.Parent = prompt

local promptCorner = Instance.new("UICorner")
promptCorner.CornerRadius = UDim.new(0, 12)
promptCorner.Parent = prompt

local actionLabel = Instance.new("TextLabel")
actionLabel.Name = "Action"
actionLabel.Position = UDim2.fromOffset(18, 8)
actionLabel.Size = UDim2.new(1, -110, 0, 32)
actionLabel.BackgroundTransparency = 1
actionLabel.Font = Enum.Font.GothamBold
actionLabel.TextColor3 = Color3.new(1, 1, 1)
actionLabel.TextSize = 21
actionLabel.TextXAlignment = Enum.TextXAlignment.Left
actionLabel.Parent = prompt

local objectLabel = Instance.new("TextLabel")
objectLabel.Name = "Object"
objectLabel.Position = UDim2.fromOffset(18, 40)
objectLabel.Size = UDim2.new(1, -110, 0, 28)
objectLabel.BackgroundTransparency = 1
objectLabel.Font = Enum.Font.Gotham
objectLabel.TextColor3 = Color3.fromRGB(205, 205, 205)
objectLabel.TextSize = 16
objectLabel.TextTruncate = Enum.TextTruncate.AtEnd
objectLabel.TextXAlignment = Enum.TextXAlignment.Left
objectLabel.Parent = prompt

local inputHint = Instance.new("TextLabel")
inputHint.Name = "InputHint"
inputHint.AnchorPoint = Vector2.new(1, 0.5)
inputHint.Position = UDim2.new(1, -16, 0.5, 0)
inputHint.Size = UDim2.fromOffset(72, 48)
inputHint.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputHint.Font = Enum.Font.GothamBold
inputHint.TextColor3 = Color3.fromRGB(25, 25, 25)
inputHint.TextSize = 16
inputHint.Parent = prompt

local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 10)
hintCorner.Parent = inputHint

local touchButton = Instance.new("TextButton")
touchButton.Name = "TouchInteract"
touchButton.AnchorPoint = Vector2.new(1, 1)
touchButton.Position = UDim2.new(1, -24, 1, -118)
touchButton.Size = UDim2.fromOffset(104, 104)
touchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
touchButton.Font = Enum.Font.GothamBold
touchButton.Text = "INTERACT"
touchButton.TextColor3 = Color3.fromRGB(25, 25, 25)
touchButton.TextSize = 15
touchButton.Visible = false
touchButton.Parent = gui

local touchCorner = Instance.new("UICorner")
touchCorner.CornerRadius = UDim.new(1, 0)
touchCorner.Parent = touchButton

local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.fromScale(0.5, 0.5)
crosshair.Size = UDim2.fromOffset(8, 8)
crosshair.BackgroundColor3 = Color3.new(1, 1, 1)
crosshair.Visible = false
crosshair.Parent = gui

local crosshairCorner = Instance.new("UICorner")
crosshairCorner.CornerRadius = UDim.new(1, 0)
crosshairCorner.Parent = crosshair

local function getInputMode(inputType: Enum.UserInputType): InputMode
	if inputType == Enum.UserInputType.Touch then
		return "Touch"
	end

	if string.find(inputType.Name, "Gamepad", 1, true) then
		return "Gamepad"
	end

	return "MouseKeyboard"
end

local function isInRange(target: InteractionTarget): boolean
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local maxDistance = target:GetAttribute(InteractionConfig.Attributes.MaxDistance)

	if not rootPart or not rootPart:IsA("BasePart") or typeof(maxDistance) ~= "number" then
		return false
	end

	return (rootPart.Position - getClosestPoint(target, rootPart.Position)).Magnitude <= maxDistance
end

local function isValidTarget(instance: Instance?): boolean
	if not instance or not instance:IsA("Model") then
		return false
	end

	if not CollectionService:HasTag(instance, InteractionConfig.Tag) or not isInRange(instance) then
		return false
	end

	local scope = instance:GetAttribute(InteractionConfig.Attributes.Scope)
	return scope == InteractionConfig.Scopes.Shared
		or (
			scope == InteractionConfig.Scopes.OwnedPlot
			and instance:GetAttribute(InteractionConfig.Attributes.OwnerUserId) == player.UserId
		)
end

local function getInteractionTarget(instance: Instance?): InteractionTarget?
	local current = instance

	while current and current ~= workspace do
		if isValidTarget(current) then
			return current :: InteractionTarget
		end

		current = current.Parent
	end

	return nil
end

local function getRaycastParams(): RaycastParams
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = if player.Character then { player.Character, plotSpawns } else { plotSpawns }
	return params
end

local function raycastFromViewportPoint(viewportPoint: Vector2): InteractionTarget?
	local camera = workspace.CurrentCamera

	if not camera then
		return nil
	end

	local ray = camera:ViewportPointToRay(viewportPoint.X, viewportPoint.Y)
	local result = workspace:Raycast(ray.Origin, ray.Direction * 500, getRaycastParams())

	if result then
		return getInteractionTarget(result.Instance)
	end

	return nil
end

local function hasLineOfSight(target: InteractionTarget): boolean
	local camera = workspace.CurrentCamera

	if not camera then
		return false
	end

	for _, descendant in target:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		local targetPoint = getClosestPoint(descendant, camera.CFrame.Position)
		local result = workspace:Raycast(camera.CFrame.Position, (targetPoint - camera.CFrame.Position) * 1.01, getRaycastParams())

		if result and result.Instance:IsDescendantOf(target) then
			return true
		end
	end

	return false
end

local function getFallbackTarget(): InteractionTarget?
	local camera = workspace.CurrentCamera

	if not camera then
		return nil
	end

	local viewportCenter = camera.ViewportSize * 0.5
	local bestTarget: InteractionTarget?
	local bestScore = math.huge

	for _, instance in CollectionService:GetTagged(InteractionConfig.Tag) do
		if not isValidTarget(instance) or not hasLineOfSight(instance :: InteractionTarget) then
			continue
		end

		local target = instance :: InteractionTarget
		local targetPosition = target:GetBoundingBox()
		local screenPosition, isVisible = camera:WorldToViewportPoint(targetPosition.Position)

		if not isVisible or screenPosition.Z <= 0 then
			continue
		end

		local screenDistance = (Vector2.new(screenPosition.X, screenPosition.Y) - viewportCenter).Magnitude

		if screenDistance > Local.FALLBACK_SCREEN_RADIUS then
			continue
		end

		local worldDistance = (targetPosition.Position - camera.CFrame.Position).Magnitude
		local score = screenDistance + worldDistance * 2

		if score < bestScore then
			bestScore = score
			bestTarget = target
		end
	end

	return bestTarget
end

local function getTarget(): InteractionTarget?
	local camera = workspace.CurrentCamera

	if not camera then
		return nil
	end

	if Local.inputMode == "MouseKeyboard" then
		local inset = GuiService:GetGuiInset()
		local mousePosition = UserInputService:GetMouseLocation() - inset
		return raycastFromViewportPoint(mousePosition)
	end

	local target = raycastFromViewportPoint(camera.ViewportSize * 0.5)

	return target or getFallbackTarget()
end

local function activateTarget(target: InteractionTarget?)
	if target and isValidTarget(target) then
		interactionEvent:FireServer(target)
	end
end

local function activateFocusedTarget()
	activateTarget(Local.focusedTarget)
end

local function activateMouseTarget()
	local inset = GuiService:GetGuiInset()
	local mousePosition = UserInputService:GetMouseLocation() - inset
	local target = raycastFromViewportPoint(mousePosition)

	if target then
		Local.focusedTarget = target
	end

	activateTarget(target)
end

local function updatePrompt()
	local target = Local.focusedTarget
	local hasTarget = target ~= nil

	highlight.Adornee = target
	highlight.Enabled = hasTarget
	prompt.Visible = hasTarget
	touchButton.Visible = hasTarget and Local.inputMode == "Touch"
	crosshair.Visible = Local.inputMode ~= "MouseKeyboard"

	if not target then
		return
	end

	local actionText = target:GetAttribute(InteractionConfig.Attributes.ActionText)
	local objectText = target:GetAttribute(InteractionConfig.Attributes.ObjectText)

	actionLabel.Text = if typeof(actionText) == "string" then actionText else "Interact"
	objectLabel.Text = if typeof(objectText) == "string" then objectText else target.Name

	if Local.inputMode == "Touch" then
		inputHint.Text = "TAP"
	elseif Local.inputMode == "Gamepad" then
		inputHint.Text = "X"
	else
		inputHint.Text = "E / CLICK"
	end
end

function InteractionController.Start()
	if Local.started then
		return
	end

	Local.started = true
	Local.inputMode = getInputMode(UserInputService:GetLastInputType())

	UserInputService.LastInputTypeChanged:Connect(function(inputType)
		Local.inputMode = getInputMode(inputType)
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			activateMouseTarget()
			return
		end

		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.E
			or input.KeyCode == Enum.KeyCode.ButtonX then
			activateFocusedTarget()
		end
	end)

	touchButton.Activated:Connect(activateFocusedTarget)

	RunService.RenderStepped:Connect(function()
		Local.focusedTarget = getTarget()
		updatePrompt()
	end)
end

return InteractionController
