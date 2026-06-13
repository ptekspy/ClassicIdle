--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	title: string,
	description: string,
	progressText: string,
	visible: boolean,
}

local function QuestCard(props: Props)
	return React.createElement("Frame", {
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.new(0.38, 0, 0, 150),
		BackgroundTransparency = 1,
		Visible = props.visible,
	}, {
		Constraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(280, 150),
			MaxSize = Vector2.new(460, 150),
		}),
		Panel = React.createElement(Panel, {
			variant = "Quest",
			size = UDim2.fromScale(1, 1),
			children = {
				Heading = React.createElement(Text, {
					text = "CURRENT QUEST",
					variant = "Caption",
					color = "Yellow",
					position = UDim2.fromOffset(16, 10),
					size = UDim2.new(1, -32, 0, 22),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
				Title = React.createElement(Text, {
					text = props.title,
					variant = "Label",
					color = "Primary",
					position = UDim2.fromOffset(16, 32),
					size = UDim2.new(1, -32, 0, 30),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
				Description = React.createElement(Text, {
					text = props.description,
					variant = "Caption",
					color = "Secondary",
					position = UDim2.fromOffset(16, 64),
					size = UDim2.new(1, -32, 0, 42),
					wrapped = true,
					textXAlignment = Enum.TextXAlignment.Left,
					textYAlignment = Enum.TextYAlignment.Top,
				}),
				Progress = React.createElement(Text, {
					text = props.progressText,
					variant = "Caption",
					color = "Primary",
					position = UDim2.fromOffset(16, 112),
					size = UDim2.new(1, -32, 0, 24),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
			},
		}),
	})
end

return QuestCard
