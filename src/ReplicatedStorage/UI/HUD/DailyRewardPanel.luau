--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local HUD = require(ReplicatedStorage.UI.Config.HUDConfig)
local Button = require(ReplicatedStorage.UI.Components.Button)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local ProgressBar = require(ReplicatedStorage.UI.Components.ProgressBar)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

local function DailyRewardPanel()
	local progress = HUD.Demo.DailyMinutes / HUD.Demo.DailyRequiredMinutes

	return React.createElement(Panel, {
		variant = "Standard",
		size = UDim2.new(1, 0, 0, 170),
		layoutOrder = 2,
		children = {
			Icon = React.createElement("Frame", {
				Position = UDim2.fromScale(0.04, 0.08),
				Size = UDim2.fromScale(0.18, 0.38),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Image = React.createElement(Icon, {
					icon = "Gift",
					size = "Large",
				}),
			}),
			Heading = React.createElement(Text, {
				text = "Daily Reward",
				variant = "Heading",
				color = "Primary",
				position = UDim2.fromScale(0.24, 0.06),
				size = UDim2.fromScale(0.7, 0.22),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			Description = React.createElement(Text, {
				text = `Play for {HUD.Demo.DailyRequiredMinutes} Minutes`,
				variant = "Body",
				color = "Secondary",
				position = UDim2.fromScale(0.24, 0.28),
				size = UDim2.fromScale(0.7, 0.18),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			ProgressText = React.createElement(Text, {
				text = `{HUD.Demo.DailyMinutes} / {HUD.Demo.DailyRequiredMinutes}`,
				variant = "Caption",
				color = "Primary",
				position = UDim2.fromScale(0.05, 0.5),
				size = UDim2.fromScale(0.55, 0.14),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			Progress = React.createElement("Frame", {
				Position = UDim2.fromScale(0.05, 0.65),
				Size = UDim2.fromScale(0.55, 0.1),
				BackgroundTransparency = 1,
			}, {
				Bar = React.createElement(ProgressBar, {
					value = progress,
					variant = "Green",
					size = UDim2.fromScale(1, 1),
				}),
			}),
			Reward = React.createElement(Text, {
				text = `{HUD.Demo.DailyCoins} Coins`,
				variant = "Label",
				color = "Yellow",
				position = UDim2.fromScale(0.05, 0.78),
				size = UDim2.fromScale(0.55, 0.18),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			Claim = React.createElement("Frame", {
				Position = UDim2.fromScale(0.66, 0.58),
				Size = UDim2.fromScale(0.29, 0.3),
				BackgroundTransparency = 1,
			}, {
				Button = React.createElement(Button, {
					text = "Claim!",
					variant = "GreenHero",
					size = UDim2.fromScale(1, 1),
					onActivated = nil,
				}),
			}),
		},
	})
end

return DailyRewardPanel
