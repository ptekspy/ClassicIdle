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

local HOTBAR_AREA_LEFT = 376
local HOTBAR_AREA_RIGHT = 604
local HOTBAR_WIDTH_SCALE = 0.9

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

local function frame(
	position: UDim2,
	size: UDim2,
	child: React.ReactNode,
	anchorPoint: Vector2?
): React.ReactNode
	return React.createElement("Frame", {
		AnchorPoint = anchorPoint or Vector2.new(0, 0),
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
		Invite = frame(
			UDim2.fromOffset(0, 15),
			UDim2.fromOffset(300, 130),
			inviteFriends()
		),

		Collapse = frame(
			UDim2.fromOffset(316, 65),
			UDim2.fromOffset(44, 60),
			React.createElement(IconButton, {
				icon = "Collapse",
				size = UDim2.fromScale(1, 1),
				onActivated = nil,
			})
		),

		HotbarArea = frame(
			UDim2.fromOffset(HOTBAR_AREA_LEFT, 30),
			UDim2.new(1, -(HOTBAR_AREA_LEFT + HOTBAR_AREA_RIGHT), 0, 120),
			React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(HOTBAR_WIDTH_SCALE, 1),
				BackgroundTransparency = 1,
			}, {
				Hotbar = React.createElement(FactoryHotbar, {
					inventory = props.inventory,
					onSelectItem = props.onSelectItem,
				}),
			})
		),

		Backpack = frame(
			UDim2.new(1, -464, 0, 5),
			UDim2.fromOffset(120, 145),
			React.createElement(ActionTile, {
				icon = "Backpack",
				label = "Backpack",
				badge = tostring(HUD.Demo.BackpackBadge),
				onActivated = nil,
			}),
			Vector2.new(1, 0)
		),

		Launch = frame(
			UDim2.new(1, -4, 0, -20),
			UDim2.fromOffset(440, 170),
			React.createElement(LaunchButton, {
				compact = false,
			}),
			Vector2.new(1, 0)
		),
	})
end

return BottomDock