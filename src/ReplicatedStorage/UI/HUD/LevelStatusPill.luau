--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local HUD = require(ReplicatedStorage.UI.Config.HUDConfig)
local ProgressBar = require(ReplicatedStorage.UI.Components.ProgressBar)
local StatusPill = require(ReplicatedStorage.UI.Components.StatusPill)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	xp: number,
}

local function getLevelProgress(totalXP: number): (number, number, number)
	local level = 1
	local spent = 0
	while totalXP - spent >= HUD.Level.BaseRequirement * level do
		spent += HUD.Level.BaseRequirement * level
		level += 1
	end
	local required = HUD.Level.BaseRequirement * level
	return level, totalXP - spent, required
end

local function LevelStatusPill(props: Props)
	local level, current, required = getLevelProgress(props.xp)

	return React.createElement(StatusPill, {
		size = UDim2.fromScale(1, 1),
		children = {
			Icon = React.createElement("Frame", {
				Position = UDim2.fromScale(0.04, 0),
				Size = UDim2.fromScale(0.24, 1),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Image = React.createElement(Icon, {
					icon = "Level",
					size = "Medium",
				}),
			}),
			Heading = React.createElement(Text, {
				text = `Level {level}`,
				variant = "Label",
				color = "Primary",
				position = UDim2.fromScale(0.29, 0.08),
				size = UDim2.fromScale(0.66, 0.36),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			Progress = React.createElement("Frame", {
				Position = UDim2.fromScale(0.32, 0.56),
				Size = UDim2.fromScale(0.63, 0.2),
				BackgroundTransparency = 1,
			}, {
				Bar = React.createElement(ProgressBar, {
					value = current / required,
					variant = "XP",
					size = UDim2.fromScale(1, 1),
				}),
			}),
			ProgressText = React.createElement(Text, {
				text = `{current} / {required}`,
				variant = "Caption",
				color = "Primary",
				position = UDim2.fromScale(0.32, 0.48),
				size = UDim2.fromScale(0.63, 0.34),
			}),
		},
	})
end

return LevelStatusPill
