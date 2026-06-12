--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)
local InteractionController = require(script.Parent.Controllers.InteractionController)
local WorkerController = require(script.Parent.Controllers.WorkerController)
local MachineController = require(script.Parent.Controllers.MachineController)
local QuestController = require(script.Parent.Controllers.QuestController)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local feedbackEvent = RemoteManager.FeedbackEvent :: RemoteEvent

local feedbackGui = Instance.new("ScreenGui")
feedbackGui.Name = "FeedbackGui"
feedbackGui.IgnoreGuiInset = true
feedbackGui.ResetOnSpawn = false
feedbackGui.DisplayOrder = 10
feedbackGui.Parent = playerGui

local currentLabel: TextLabel?

local function showFeedback(message: string)
	if currentLabel then
		currentLabel:Destroy()
	end

	local label = Instance.new("TextLabel")
	label.Name = "Feedback"
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.88)
	label.Size = UDim2.new(0.85, 0, 0, 60)
	label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = message
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 22
	label.TextTransparency = 1
	label.TextWrapped = true
	label.Parent = feedbackGui

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MaxSize = Vector2.new(420, 60)
	sizeConstraint.MinSize = Vector2.new(220, 60)
	sizeConstraint.Parent = label

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label

	currentLabel = label

	local showTween = TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.15,
		Position = UDim2.fromScale(0.5, 0.82),
		TextTransparency = 0,
	})

	showTween:Play()
	showTween.Completed:Wait()
	task.wait(1.8)

	if currentLabel ~= label then
		return
	end

	local hideTween = TweenService:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.77),
		TextTransparency = 1,
	})

	hideTween:Play()
	hideTween.Completed:Wait()

	if currentLabel == label then
		currentLabel = nil
		label:Destroy()
	end
end

feedbackEvent.OnClientEvent:Connect(showFeedback)

InteractionController.Start()
WorkerController.Start()
MachineController.Start()
QuestController.Start()
