--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local HUD = require(ReplicatedStorage.UI.Config.HUDConfig)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local ProgressBar = require(ReplicatedStorage.UI.Components.ProgressBar)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	visible: boolean,
}

local SEGMENT_COUNT = 20
local PROGRESS_START = 0.235
local PROGRESS_WIDTH = 0.53

local function iconHost(icon: string, position: UDim2): React.ReactNode
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = position,
		Size = UDim2.fromOffset(70, 70),
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Icon = React.createElement(Icon, {
			icon = icon,
			size = "Large",
		}),
	})
end

local function ZoneProgressBar(props: Props)
	local percentage = math.floor(HUD.Demo.ZoneProgress * 100 + 0.5)
	local filledSegments = math.floor(HUD.Demo.ZoneProgress * SEGMENT_COUNT + 0.5)
	local filledWidth = PROGRESS_WIDTH * filledSegments / SEGMENT_COUNT

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = props.visible,
	}, {
		Panel = React.createElement(Panel, {
			variant = "Status",
			size = UDim2.fromScale(1, 1),
			children = {
				Earth = iconHost("Earth", UDim2.fromScale(0.045, 0.5)),
				EarthLabel = React.createElement(Text, {
					text = "EARTH ZONE",
					variant = "Label",
					color = "Primary",
					position = UDim2.fromScale(0.08, 0.08),
					size = UDim2.fromScale(0.15, 0.46),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
				Progress = React.createElement("Frame", {
					Position = UDim2.fromScale(PROGRESS_START, 0.18),
					Size = UDim2.fromScale(PROGRESS_WIDTH, 0.34),
					BackgroundTransparency = 1,
				}, {
					Bar = React.createElement(ProgressBar, {
						value = HUD.Demo.ZoneProgress,
						variant = "Zone",
						size = UDim2.fromScale(1, 1),
						segmented = SEGMENT_COUNT,
					}),
				}),
				Complete = React.createElement(Text, {
					text = `{percentage}% COMPLETE`,
					variant = "Caption",
					color = "Secondary",
					position = UDim2.fromScale(PROGRESS_START, 0.54),
					size = UDim2.fromScale(filledWidth, 0.32),
				}),
				MoonLabel = React.createElement(Text, {
					text = "MOON ZONE",
					variant = "Label",
					color = "Primary",
					position = UDim2.fromScale(0.77, 0.08),
					size = UDim2.fromScale(0.15, 0.46),
					textXAlignment = Enum.TextXAlignment.Right,
				}),
				Moon = iconHost("Moon", UDim2.fromScale(0.955, 0.5)),
			},
		}),
	})
end

return ZoneProgressBar
