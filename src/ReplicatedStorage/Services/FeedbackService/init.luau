--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)

local FeedbackService = {}

local feedbackEvent = RemoteManager.FeedbackEvent :: RemoteEvent

function FeedbackService.Send(player: Player, message: string)
	feedbackEvent:FireClient(player, message)
end

return FeedbackService
