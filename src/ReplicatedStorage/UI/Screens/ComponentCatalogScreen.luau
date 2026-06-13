--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Vendor.React)
local ActionTile = require(ReplicatedStorage.UI.Components.ActionTile)
local Button = require(ReplicatedStorage.UI.Components.Button)
local CurrencyPill = require(ReplicatedStorage.UI.Components.CurrencyPill)
local HotbarSlot = require(ReplicatedStorage.UI.Components.HotbarSlot)
local NotificationBadge = require(ReplicatedStorage.UI.Components.NotificationBadge)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local ProgressBar = require(ReplicatedStorage.UI.Components.ProgressBar)
local RewardCard = require(ReplicatedStorage.UI.Components.RewardCard)
local StatusPill = require(ReplicatedStorage.UI.Components.StatusPill)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)
local Corner = require(ReplicatedStorage.UI.Primitives.Corner)
local Gradient = require(ReplicatedStorage.UI.Primitives.Gradient)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Padding = require(ReplicatedStorage.UI.Primitives.Padding)
local Stroke = require(ReplicatedStorage.UI.Primitives.Stroke)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

local NOOP = function() end
local COLUMN_COUNT = 6
local CORNER_VARIANTS: { Types.CornerVariant } = { "Small", "Medium", "Large", "Pill" }
local STROKE_VARIANTS: { Types.StrokeVariant } = { "Outer", "Blue", "Purple" }
local GRADIENT_VARIANTS: { Types.GradientVariant } =
	{ "PanelBlue", "PanelPurple", "ButtonGreen", "ButtonDisabled", "Progress" }
local TEXT_VARIANTS: { Types.TextVariant } = { "Caption", "Body", "Label", "Heading", "Hero" }
local ICON_SIZES: { Types.IconSize } = { "Tiny", "Small", "Medium", "Large", "ActionTile", "Hero" }
local PANEL_VARIANTS: { Types.PanelVariant } = { "Standard", "Quest", "Event", "Status" }
local PROGRESS_VARIANTS: { Types.ProgressVariant } = { "Green", "Zone", "XP" }

local function preview(label: string, child: React.ReactNode, order: number): React.ReactNode
	return React.createElement("Frame", {
		LayoutOrder = order,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Label = React.createElement(Text, {
			text = label,
			variant = "Caption",
			color = "Secondary",
			size = UDim2.new(1, 0, 0, 24),
		}),
		Host = React.createElement("Frame", {
			Position = UDim2.fromOffset(0, 28),
			Size = UDim2.new(1, 0, 1, -28),
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Preview = React.createElement(React.Fragment, nil, child),
		}),
	})
end

local function section(title: string, order: number, cellHeight: number, cells: { React.ReactNode }): React.ReactNode
	local rows = math.ceil(#cells / COLUMN_COUNT)
	local height = 62 + rows * cellHeight
	local gridChildren: { [string]: React.ReactNode } = {
		Grid = React.createElement("UIGridLayout", {
			CellSize = UDim2.new(1 / COLUMN_COUNT, -14, 0, cellHeight - 12),
			CellPadding = UDim2.fromOffset(14, 12),
			FillDirectionMaxCells = COLUMN_COUNT,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for index, cell in cells do
		gridChildren[`Cell{index}`] = cell
	end

	return React.createElement("Frame", {
		LayoutOrder = order,
		Size = UDim2.new(1, -32, 0, height),
		BackgroundTransparency = 1,
	}, {
		Panel = React.createElement(Panel, {
			variant = "Status",
			size = UDim2.fromScale(1, 1),
			children = {
				Title = React.createElement(Text, {
					text = title,
					variant = "Heading",
					color = "Primary",
					position = UDim2.fromOffset(18, 10),
					size = UDim2.new(1, -36, 0, 34),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
				Grid = React.createElement("Frame", {
					Position = UDim2.fromOffset(18, 48),
					Size = UDim2.new(1, -36, 1, -58),
					BackgroundTransparency = 1,
				}, gridChildren),
			},
		}),
	})
end

local function sampleFrame(child: React.ReactNode): React.ReactNode
	return React.createElement("Frame", {
		Size = UDim2.fromOffset(130, 70),
		BackgroundColor3 = Colors.Panel.Primary,
	}, {
		Decoration = React.createElement(React.Fragment, nil, child),
	})
end

local function primitiveCells(): { React.ReactNode }
	local cells = {}
	local order = 0

	for _, variant in CORNER_VARIANTS do
		order += 1
		table.insert(
			cells,
			preview(`Corner: {variant}`, sampleFrame(React.createElement(Corner, { variant = variant })), order)
		)
	end

	for _, variant in STROKE_VARIANTS do
		order += 1
		table.insert(
			cells,
			preview(`Stroke: {variant}`, sampleFrame(React.createElement(Stroke, { variant = variant })), order)
		)
	end

	for _, variant in GRADIENT_VARIANTS do
		order += 1
		table.insert(
			cells,
			preview(`Gradient: {variant}`, sampleFrame(React.createElement(Gradient, { variant = variant })), order)
		)
	end

	return cells
end

local function textCells(): { React.ReactNode }
	local cells = {}
	for order, variant in TEXT_VARIANTS do
		table.insert(
			cells,
			preview(
				variant,
				React.createElement(Text, {
					text = variant,
					variant = variant,
					color = "Primary",
					size = UDim2.fromOffset(190, 70),
				}),
				order
			)
		)
	end
	return cells
end

local function iconSizeCells(): { React.ReactNode }
	local cells = {}
	for order, size in ICON_SIZES do
		table.insert(
			cells,
			preview(
				size,
				React.createElement(Icon, {
					icon = "Rocket",
					size = size,
				}),
				order
			)
		)
	end
	return cells
end

local function iconAssetCells(): { React.ReactNode }
	local cells = {}
	local icons = {
		"Gold",
		"Gems",
		"Fuel",
		"Trophy",
		"Level",
		"Wheel",
		"Calendar",
		"Earth",
		"Moon",
		"Gift",
		"Meteor",
		"Shop",
		"Rocket",
		"Pets",
		"Rebirth",
		"Codes",
		"Settings",
		"Friends",
		"Backpack",
		"Lock",
		"Collapse",
	}
	for order, icon in icons do
		table.insert(
			cells,
			preview(
				icon,
				React.createElement(Icon, {
					icon = icon,
					size = "Large",
				}),
				order
			)
		)
	end
	return cells
end

local function panelCells(): { React.ReactNode }
	local cells = {}
	for order, variant in PANEL_VARIANTS do
		table.insert(
			cells,
			preview(
				variant,
				React.createElement(Panel, {
					variant = variant,
					size = UDim2.fromOffset(190, 82),
					children = {
						Label = React.createElement(Text, {
							text = variant,
							variant = "Label",
							color = "Primary",
							size = UDim2.fromScale(1, 1),
						}),
					},
				}),
				order
			)
		)
	end
	return cells
end

local function buttonCells(): { React.ReactNode }
	local examples: { { label: string, text: string, variant: Types.ButtonVariant, callback: (() -> ())? } } = {
		{ label = "Enabled", text = "Enabled", variant = "Primary", callback = NOOP },
		{ label = "Hovered", text = "Hover Me", variant = "Primary", callback = NOOP },
		{ label = "Pressed", text = "Hold Me", variant = "GreenHero", callback = NOOP },
		{ label = "Selected", text = "Gamepad Select", variant = "Secondary", callback = NOOP },
		{ label = "Disabled", text = "Disabled", variant = "Disabled", callback = nil },
	}
	local cells = {}
	for order, example in examples do
		table.insert(
			cells,
			preview(
				example.label,
				React.createElement(Button, {
					text = example.text,
					variant = example.variant,
					size = UDim2.fromOffset(190, 64),
					onActivated = example.callback,
				}),
				order
			)
		)
	end
	return cells
end

local function badgeCells(): { React.ReactNode }
	local cells = {}
	for order, value in { "!", "2", "99+" } do
		table.insert(
			cells,
			preview(
				`Badge: {value}`,
				React.createElement("Frame", {
					Size = UDim2.fromOffset(80, 60),
					BackgroundTransparency = 1,
				}, {
					Badge = React.createElement(NotificationBadge, {
						text = value,
						position = UDim2.fromScale(0.5, 0.5),
					}),
				}),
				order
			)
		)
	end
	return cells
end

local function progressCells(): { React.ReactNode }
	local cells = {}
	local order = 0
	for _, variant in PROGRESS_VARIANTS do
		for _, value in { 0, 0.25, 0.68, 1 } do
			order += 1
			table.insert(
				cells,
				preview(
					`{variant}: {value}`,
					React.createElement(ProgressBar, {
						value = value,
						variant = variant,
						size = UDim2.fromOffset(190, 24),
						segmented = if variant == "Zone" then 8 else nil,
					}),
					order
				)
			)
		end
	end
	return cells
end

local function pillCells(): { React.ReactNode }
	return {
		preview(
			"Gold",
			React.createElement(CurrencyPill, {
				icon = "Gold",
				value = "12.5K",
				showPlus = true,
				enabled = false,
			}),
			1
		),
		preview(
			"Gems",
			React.createElement(CurrencyPill, {
				icon = "Gems",
				value = "1,250",
				showPlus = true,
				enabled = false,
			}),
			2
		),
		preview(
			"Fuel",
			React.createElement(CurrencyPill, {
				icon = "Fuel",
				value = "2,850",
				showPlus = true,
				enabled = false,
			}),
			3
		),
		preview(
			"Status",
			React.createElement(StatusPill, {
				size = UDim2.fromOffset(220, 72),
				children = {
					Label = React.createElement(Text, {
						text = "Best: 12.45 km",
						variant = "Label",
						color = "Primary",
						size = UDim2.fromScale(1, 1),
					}),
				},
			}),
			4
		),
	}
end

local function actionCells(): { React.ReactNode }
	local examples = {
		{ "Shop", "Shop", "!" },
		{ "Build", "Build", "!" },
		{ "Rocket", "Rocket", "!" },
		{ "Pets", "Pets", "2" },
		{ "Worlds", "Worlds", nil },
		{ "Rebirth", "Rebirth", "!" },
		{ "Codes", "Codes", nil },
		{ "Settings", "Settings", nil },
		{ "Backpack", "Backpack", "3" },
	}
	local cells = {}
	for order, example in examples do
		table.insert(
			cells,
			preview(
				example[1],
				React.createElement(ActionTile, {
					label = example[1],
					icon = example[2],
					badge = example[3],
					onActivated = if example[1] == "Build" then NOOP else nil,
				}),
				order
			)
		)
	end
	return cells
end

local function rewardCells(): { React.ReactNode }
	return {
		preview(
			"Gems",
			React.createElement(RewardCard, {
				icon = "Gems",
				value = "x250",
				layoutOrder = 1,
			}),
			1
		),
		preview(
			"Gold",
			React.createElement(RewardCard, {
				icon = "Gold",
				value = "x10K",
				layoutOrder = 2,
			}),
			2
		),
	}
end

local function hotbarCells(): { React.ReactNode }
	return {
		preview(
			"Empty",
			React.createElement(HotbarSlot, {
				slotNumber = 1,
				layoutOrder = 1,
				onActivated = NOOP,
			}),
			1
		),
		preview(
			"Count",
			React.createElement(HotbarSlot, {
				slotNumber = 2,
				icon = "Build",
				count = 12,
				layoutOrder = 2,
				onActivated = NOOP,
			}),
			2
		),
		preview(
			"Selected",
			React.createElement(HotbarSlot, {
				slotNumber = 3,
				icon = "Build",
				count = 3,
				selected = true,
				layoutOrder = 3,
				onActivated = NOOP,
			}),
			3
		),
		preview(
			"Locked",
			React.createElement(HotbarSlot, {
				slotNumber = 4,
				locked = true,
				layoutOrder = 4,
				onActivated = nil,
			}),
			4
		),
	}
end

local function ComponentCatalogScreen()
	if not RunService:IsStudio() then
		return nil
	end

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = Layout.DisplayOrder.Overlay + 100,
	}, {
		Background = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Colors.Panel.Deep,
		}, {
			Header = React.createElement(Text, {
				text = "Design System Component Catalog",
				variant = "Hero",
				color = "Primary",
				position = UDim2.fromOffset(24, 12),
				size = UDim2.new(1, -48, 0, 54),
				textXAlignment = Enum.TextXAlignment.Left,
			}),
			Scroll = React.createElement("ScrollingFrame", {
				Position = UDim2.fromOffset(0, 76),
				Size = UDim2.new(1, 0, 1, -76),
				BackgroundTransparency = 1,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromOffset(0, 0),
				ScrollBarImageColor3 = Colors.Stroke.Blue,
				ScrollBarThickness = 10,
			}, {
				Padding = React.createElement(Padding, { size = "LG" }),
				Layout = React.createElement("UIListLayout", {
					Padding = UDim.new(0, 16),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Primitives = section("Corners, Strokes, And Gradients", 1, 120, primitiveCells()),
				Text = section("Text Variants", 2, 120, textCells()),
				IconSizes = section("Icon Size Variants", 3, 160, iconSizeCells()),
				Icons = section("Icon Assets", 4, 140, iconAssetCells()),
				Panels = section("Panel Variants", 5, 140, panelCells()),
				Buttons = section("Button Variants And Interactive States", 6, 130, buttonCells()),
				Badges = section("Badge Styles", 7, 120, badgeCells()),
				Progress = section("Progress Variants And Values", 8, 110, progressCells()),
				Pills = section("Currency And Status Pills", 9, 140, pillCells()),
				Actions = section("Action Tiles", 10, 190, actionCells()),
				Rewards = section("Reward Cards", 11, 170, rewardCells()),
				Hotbar = section("Hotbar Slot States", 12, 140, hotbarCells()),
			}),
		}),
	})
end

return ComponentCatalogScreen
