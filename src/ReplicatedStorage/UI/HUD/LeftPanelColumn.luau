--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local DailyRewardPanel = require(ReplicatedStorage.UI.HUD.DailyRewardPanel)
local LimitedEventPanel = require(ReplicatedStorage.UI.HUD.LimitedEventPanel)
local QuestPanel = require(ReplicatedStorage.UI.HUD.QuestPanel)

export type Props = {
	quest: any?,
}

local function LeftPanelColumn(props: Props)
	local quest = props.quest
	local questVisible = quest ~= nil and quest.Complete ~= true

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 22),
		}),
		Quest = React.createElement(QuestPanel, {
			title = if questVisible then quest.Title or "" else "",
			description = if questVisible then quest.Description or "" else "",
			progress = if questVisible then quest.Progress or 0 else 0,
			required = if questVisible then quest.RequiredAmount or 1 else 1,
			xpReward = if questVisible then quest.XPReward or 0 else 0,
			visible = questVisible,
		}),
		Daily = React.createElement(DailyRewardPanel),
		Event = React.createElement(LimitedEventPanel),
	})
end

return LeftPanelColumn
