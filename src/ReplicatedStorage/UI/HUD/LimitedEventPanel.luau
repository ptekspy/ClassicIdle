--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local HUD = require(ReplicatedStorage.UI.Config.HUDConfig)
local Button = require(ReplicatedStorage.UI.Components.Button)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local RewardCard = require(ReplicatedStorage.UI.Components.RewardCard)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

local function LimitedEventPanel()
	return React.createElement(Panel, {
		variant = "Event",
		size = UDim2.new(1, 0, 0, 300),
		layoutOrder = 3,
		children = {
			Header = React.createElement(Text, {
				text = "Limited Event",
				variant = "Heading",
				color = "Primary",
				position = UDim2.fromScale(0.05, 0.03),
				size = UDim2.fromScale(0.56, 0.12),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			Time = React.createElement(Text, {
				text = HUD.Demo.EventTime,
				variant = "Caption",
				color = "Yellow",
				position = UDim2.fromScale(0.63, 0.04),
				size = UDim2.fromScale(0.32, 0.1),
				textXAlignment = Enum.TextXAlignment.Right,
			}),
			Meteor = React.createElement("Frame", {
				Position = UDim2.fromScale(0.05, 0.16),
				Size = UDim2.fromScale(0.25, 0.26),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Icon = React.createElement(Icon, {
					icon = "Meteor",
					size = "Large",
				}),
			}),
			Title = React.createElement(Text, {
				text = HUD.Demo.EventTitle,
				variant = "Heading",
				color = "Yellow",
				position = UDim2.fromScale(0.3, 0.17),
				size = UDim2.fromScale(0.65, 0.12),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			Subtitle = React.createElement(Text, {
				text = "Limited-time rewards",
				variant = "Body",
				color = "Secondary",
				position = UDim2.fromScale(0.3, 0.29),
				size = UDim2.fromScale(0.65, 0.1),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			Rewards = React.createElement("Frame", {
				Position = UDim2.fromScale(0.1, 0.44),
				Size = UDim2.fromScale(0.8, 0.36),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 18),
				}),
				Gems = React.createElement(RewardCard, {
					icon = "Gems",
					value = HUD.Demo.EventGems,
					layoutOrder = 1,
				}),
				Coins = React.createElement(RewardCard, {
					icon = "Gold",
					value = HUD.Demo.EventCoins,
					layoutOrder = 2,
				}),
			}),
			Join = React.createElement("Frame", {
				Position = UDim2.fromScale(0.2, 0.82),
				Size = UDim2.fromScale(0.6, 0.14),
				BackgroundTransparency = 1,
			}, {
				Button = React.createElement(Button, {
					text = "Join Event!",
					variant = "GreenHero",
					size = UDim2.fromScale(1, 1),
					onActivated = nil,
				}),
			}),
		},
	})
end

return LimitedEventPanel
