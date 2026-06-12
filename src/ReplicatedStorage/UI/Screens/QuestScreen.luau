--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local QuestCard = require(script.Parent.Parent.Components.QuestCard)
local QuestTargetMarker = require(script.Parent.Parent.Components.QuestTargetMarker)

export type Props = {
	quest: any?,
	questMarker: BasePart?,
}

local function QuestScreen(props: Props)
	local quest = props.quest
	local visible = quest ~= nil and quest.Complete ~= true
	local progressText = ""

	if visible then
		progressText = `{math.floor(quest.Progress * 100) / 100}/{quest.RequiredAmount}  •  +{quest.XPReward} XP`
	end

	return React.createElement("ScreenGui", {
		Name = "QuestGui",
		DisplayOrder = 15,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Card = React.createElement(QuestCard, {
			title = if visible then quest.Title else "",
			description = if visible then quest.Description else "",
			progressText = progressText,
			visible = visible,
		}),
		Marker = React.createElement(QuestTargetMarker, {
			adornee = props.questMarker,
		}),
	})
end

return QuestScreen
