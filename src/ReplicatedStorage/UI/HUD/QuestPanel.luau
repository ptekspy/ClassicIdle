--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Button = require(ReplicatedStorage.UI.Components.Button)
local NotificationBadge = require(ReplicatedStorage.UI.Components.NotificationBadge)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local ProgressBar = require(ReplicatedStorage.UI.Components.ProgressBar)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	title: string,
	description: string,
	progress: number,
	required: number,
	xpReward: number,
	visible: boolean,
}

local function iconHost(icon: string, position: UDim2, size: UDim2): React.ReactNode
	return React.createElement("Frame", {
		Position = position,
		Size = size,
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Icon = React.createElement(Icon, {
			icon = icon,
			size = "Medium",
		}),
	})
end

local function QuestPanel(props: Props)
	local required = math.max(props.required, 1)
	local progress = math.clamp(props.progress, 0, required)

	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 158),
		LayoutOrder = 1,
		BackgroundTransparency = 1,
		Visible = props.visible,
	}, {
		Panel = React.createElement(Panel, {
			variant = "Quest",
			size = UDim2.fromScale(1, 1),
			children = {
				QuestIcon = iconHost("Quest", UDim2.fromScale(0.025, 0.02), UDim2.fromScale(0.16, 0.38)),
				Heading = React.createElement(Text, {
					text = "Main Quest",
					variant = "Heading",
					color = "Primary",
					position = UDim2.fromScale(0.18, 0.02),
					size = UDim2.fromScale(0.62, 0.24),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
				Badge = React.createElement(NotificationBadge, {
					text = "!",
					position = UDim2.fromScale(0.91, 0.12),
				}),
				Title = React.createElement(Text, {
					text = props.title,
					variant = "Label",
					color = "Yellow",
					position = UDim2.fromScale(0.05, 0.27),
					size = UDim2.fromScale(0.65, 0.18),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
				Description = React.createElement(Text, {
					text = props.description,
					variant = "Caption",
					color = "Secondary",
					position = UDim2.fromScale(0.05, 0.45),
					size = UDim2.fromScale(0.65, 0.22),
					textXAlignment = Enum.TextXAlignment.Left,
					wrapped = true,
				}),
				ProgressText = React.createElement(Text, {
					text = `{progress} / {required}`,
					variant = "Caption",
					color = "Primary",
					position = UDim2.fromScale(0.05, 0.68),
					size = UDim2.fromScale(0.43, 0.14),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
				Progress = React.createElement("Frame", {
					Position = UDim2.fromScale(0.05, 0.83),
					Size = UDim2.fromScale(0.58, 0.1),
					BackgroundTransparency = 1,
				}, {
					Bar = React.createElement(ProgressBar, {
						value = progress / required,
						variant = "Green",
						size = UDim2.fromScale(1, 1),
					}),
				}),
				RewardIcon = iconHost("Gems", UDim2.fromScale(0.66, 0.48), UDim2.fromScale(0.14, 0.22)),
				Reward = React.createElement(Text, {
					text = tostring(props.xpReward),
					variant = "Label",
					color = "Yellow",
					position = UDim2.fromScale(0.79, 0.48),
					size = UDim2.fromScale(0.16, 0.22),
				}),
				Go = React.createElement("Frame", {
					Position = UDim2.fromScale(0.68, 0.72),
					Size = UDim2.fromScale(0.27, 0.22),
					BackgroundTransparency = 1,
				}, {
					Button = React.createElement(Button, {
						text = "Go!",
						variant = "GreenHero",
						size = UDim2.fromScale(1, 1),
						onActivated = nil,
					}),
				}),
			},
		}),
	})
end

return QuestPanel
