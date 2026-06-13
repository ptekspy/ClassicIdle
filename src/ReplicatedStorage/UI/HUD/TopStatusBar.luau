--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local HUD = require(ReplicatedStorage.UI.Config.HUDConfig)
local CurrencyPill = require(ReplicatedStorage.UI.Components.CurrencyPill)
local IconButton = require(ReplicatedStorage.UI.Components.IconButton)
local StatusPill = require(ReplicatedStorage.UI.Components.StatusPill)
local LevelStatusPill = require(ReplicatedStorage.UI.HUD.LevelStatusPill)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	gold: number,
	xp: number,
}

local function slot(width: number, layoutOrder: number, child: React.ReactNode): React.ReactNode
	return React.createElement("Frame", {
		LayoutOrder = layoutOrder,
		Size = UDim2.fromOffset(width, 72),
		BackgroundTransparency = 1,
	}, {
		Content = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			Child = React.createElement(React.Fragment, nil, child),
		}),
	})
end

local function currency(icon: string, value: string): React.ReactNode
	return React.createElement(CurrencyPill, {
		icon = icon,
		value = value,
		showPlus = true,
		enabled = false,
	})
end

local function bestDistance(): React.ReactNode
	return React.createElement(StatusPill, {
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
					icon = "Trophy",
					size = "Medium",
				}),
			}),
			Heading = React.createElement(Text, {
				text = "Best Distance",
				variant = "Caption",
				color = "Primary",
				position = UDim2.fromScale(0.32, 0.08),
				size = UDim2.fromScale(0.62, 0.34),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			Value = React.createElement(Text, {
				text = HUD.Demo.BestDistance,
				variant = "Label",
				color = "Yellow",
				position = UDim2.fromScale(0.32, 0.42),
				size = UDim2.fromScale(0.62, 0.46),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
		},
	})
end

local function iconButton(icon: string, label: string?, badge: string?): React.ReactNode
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(72, 72),
		BackgroundTransparency = 1,
	}, {
		Button = React.createElement(IconButton, {
			icon = icon,
			label = label,
			badge = badge,
			size = UDim2.fromScale(1, 1),
			onActivated = nil,
		}),
	})
end

local function TopStatusBar(props: Props)
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 14),
		}),

		Gold = slot(230, 1, currency("Gold", FormatNumber.FormatCompact(props.gold))),
		Gems = slot(230, 2, currency("Gems", FormatNumber.FormatCompact(HUD.Demo.Gems))),
		Fuel = slot(230, 3, currency("Fuel", FormatNumber.FormatCompact(HUD.Demo.Fuel))),
		BestDistance = slot(220, 4, bestDistance()),
		Level = slot(280, 5, React.createElement(LevelStatusPill, { xp = props.xp })),
		Wheel = slot(72, 6, iconButton("Wheel", nil, "!")),
		Calendar = slot(72, 7, iconButton("Calendar", tostring(HUD.Demo.CalendarDay), nil)),
	})
end

return TopStatusBar