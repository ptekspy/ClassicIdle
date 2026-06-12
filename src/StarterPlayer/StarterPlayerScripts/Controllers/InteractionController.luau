--!strict

local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local UIState = require(script.Parent.Parent.UI.UIState)


local InteractionConfig = require(ReplicatedStorage.Interaction.Config)
local getClosestPoint = require(ReplicatedStorage.Interaction.getClosestPoint)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)

type InputMode = "MouseKeyboard" | "Gamepad" | "Touch"
type InteractionTarget = Model

local interactionEvent = RemoteManager.InteractionRequest :: RemoteEvent
local player = Players.LocalPlayer

local plotSpawns = workspace:WaitForChild("PlotSpawns")

local Local = {
	FALLBACK_SCREEN_RADIUS = 220,
	inputMode = "MouseKeyboard" :: InputMode,
	focusedTarget = nil :: InteractionTarget?,
	lastPublishedTarget = nil :: InteractionTarget?,
	lastPublishedInputMode = nil :: InputMode?,
	started = false,
}

local InteractionController = {}

local highlight = Instance.new("Highlight")
highlight.Name = "InteractionHighlight"
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.FillTransparency = 1
highlight.OutlineColor = Color3.new(1, 1, 1)
highlight.OutlineTransparency = 0
highlight.Enabled = false
highlight.Parent = workspace

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

	if target == Local.lastPublishedTarget and Local.inputMode == Local.lastPublishedInputMode then
		return
	end
	Local.lastPublishedTarget = target
	Local.lastPublishedInputMode = Local.inputMode

	local actionText = if target then target:GetAttribute(InteractionConfig.Attributes.ActionText) else nil
	local objectText = if target then target:GetAttribute(InteractionConfig.Attributes.ObjectText) else nil
	local inputHint = if Local.inputMode == "Touch"
		then "TAP"
		elseif Local.inputMode == "Gamepad" then "X"
		else "E / CLICK"

	UIState.Set("interaction", {
		visible = hasTarget,
		actionText = if typeof(actionText) == "string" then actionText else "Interact",
		objectText = if typeof(objectText) == "string" then objectText else if target then target.Name else "",
		inputHint = inputHint,
		inputMode = Local.inputMode,
		onActivated = activateFocusedTarget,
	})
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

	RunService.RenderStepped:Connect(function()
		Local.focusedTarget = getTarget()
		updatePrompt()
	end)
end

return InteractionController
