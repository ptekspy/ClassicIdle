--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)
local QuestTargetMarker = require(script.Parent.Parent.Components.QuestTargetMarker)

export type Props = {
	questMarker: BasePart?,
}

local function QuestScreen(props: Props)
	return React.createElement("ScreenGui", {
		DisplayOrder = Layout.DisplayOrder.QuestMarker,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Marker = React.createElement(QuestTargetMarker, {
			adornee = props.questMarker,
		}),
	})
end

return QuestScreen
