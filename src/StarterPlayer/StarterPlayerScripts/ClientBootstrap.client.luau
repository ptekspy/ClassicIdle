--!strict


local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)
local InteractionController = require(script.Parent.Controllers.InteractionController)
local WorkerController = require(script.Parent.Controllers.WorkerController)
local FactoryController = require(script.Parent.Controllers.FactoryController)
local QuestController = require(script.Parent.Controllers.QuestController)
local MachineController = require(script.Parent.Controllers.MachineController)
local feedbackEvent = RemoteManager.FeedbackEvent :: RemoteEvent

local UIRoot = require(script.Parent.UI.UIRoot)
local UIState = require(script.Parent.UI.UIState)

local feedbackId = 0

feedbackEvent.OnClientEvent:Connect(function(message: string)
	feedbackId += 1
	local thisId = feedbackId

	UIState.Set("feedback", {
		id = thisId,
		message = message,
		onFinished = function(finishedId: number)
			local feedback = UIState.Get().feedback
			if feedback and feedback.id == finishedId then
				UIState.Set("feedback", nil)
			end
		end,
	})
end)


InteractionController.Start()
WorkerController.Start()
FactoryController.Start()
QuestController.Start()
MachineController.Start()
UIRoot.Start()
