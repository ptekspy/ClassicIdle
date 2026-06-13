--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local HUD = require(ReplicatedStorage.UI.Config.HUDConfig)
local Button = require(ReplicatedStorage.UI.Components.Button)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	compact: boolean?,
}

local function LaunchButton(props: Props)
	local compact = props.compact == true

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Button = React.createElement(Button, {
			text = "",
			variant = "GreenHero",
			size = UDim2.fromScale(1, 1),
			onActivated = nil,
		}),
		Icon = React.createElement("Frame", {
			Position = UDim2.fromScale(0.02, 0),
			Size = UDim2.fromScale(if compact then 0.25 else 0.34, 1),
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Image = if compact
				then React.createElement(Icon, {
					icon = "Rocket",
					size = "Large",
				})
				else React.createElement(Icon, {
					icon = "Rocket",
					size = "Hero",
				}),
		}),
		Launch = React.createElement(Text, {
			text = "LAUNCH",
			variant = if compact then "Heading" else "Hero",
			color = "Dark",
			position = UDim2.fromScale(if compact then 0.28 else 0.35, 0.12),
			size = UDim2.fromScale(if compact then 0.67 else 0.6, 0.48),
		}),
		Cost = React.createElement(Text, {
			text = `Fuel Cost: {HUD.Demo.LaunchFuelCost}`,
			variant = if compact then "Caption" else "Label",
			color = "Dark",
			position = UDim2.fromScale(if compact then 0.28 else 0.35, 0.58),
			size = UDim2.fromScale(if compact then 0.67 else 0.6, 0.24),
		}),
	})
end

return LaunchButton
