--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local HUD = require(ReplicatedStorage.UI.Config.HUDConfig)
local ActionTile = require(ReplicatedStorage.UI.Components.ActionTile)
local IconButton = require(ReplicatedStorage.UI.Components.IconButton)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local FactoryHotbar = require(ReplicatedStorage.UI.HUD.FactoryHotbar)
local LaunchButton = require(ReplicatedStorage.UI.HUD.LaunchButton)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	inventory: { [string]: number },
	onSelectItem: ((string) -> ())?,
}

local function inviteFriends(): React.ReactNode
	return React.createElement(Panel, {
		variant = "Status",
		size = UDim2.fromScale(1, 1),
		children = {
			Icon = React.createElement("Frame", {
				Position = UDim2.fromScale(0.04, 0),
				Size = UDim2.fromScale(0.3, 1),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Image = React.createElement(Icon, {
					icon = "Friends",
					size = "Large",
				}),
			}),
			Heading = React.createElement(Text, {
				text = "Invite Friends",
				variant = "Heading",
				color = "Primary",
				position = UDim2.fromScale(0.34, 0.18),
				size = UDim2.fromScale(0.62, 0.32),
			}),
			Bonus = React.createElement(Text, {
				text = "+10% Coins",
				variant = "Label",
				color = "Yellow",
				position = UDim2.fromScale(0.34, 0.52),
				size = UDim2.fromScale(0.62, 0.26),
			}),
		},
	})
end

local function frame(position: UDim2, size: UDim2, child: React.ReactNode): React.ReactNode
	return React.createElement("Frame", {
		Position = position,
		Size = size,
		BackgroundTransparency = 1,
	}, {
		Content = React.createElement(React.Fragment, nil, child),
	})
end

local function BottomDock(props: Props)
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Invite = frame(UDim2.fromOffset(0, 15), UDim2.fromOffset(300, 130), inviteFriends()),
		Collapse = frame(
			UDim2.fromOffset(316, 65),
			UDim2.fromOffset(44, 60),
			React.createElement(IconButton, {
				icon = "Collapse",
				size = UDim2.fromScale(1, 1),
				onActivated = nil,
			})
		),
		Hotbar = frame(
			UDim2.fromOffset(376, 30),
			UDim2.fromOffset(850, 120),
			React.createElement(FactoryHotbar, {
				inventory = props.inventory,
				onSelectItem = props.onSelectItem,
			})
		),
		Backpack = frame(
			UDim2.fromOffset(1246, 5),
			UDim2.fromOffset(120, 145),
			React.createElement(ActionTile, {
				icon = "Backpack",
				label = "Backpack",
				badge = tostring(HUD.Demo.BackpackBadge),
				onActivated = nil,
			})
		),
		Launch = frame(
			UDim2.fromOffset(1386, -20),
			UDim2.fromOffset(440, 170),
			React.createElement(LaunchButton, {
				compact = false,
			})
		),
	})
end

return BottomDock
