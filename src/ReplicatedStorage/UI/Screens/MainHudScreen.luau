--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)
local PlayerDataContext = require(ReplicatedStorage.UI.Context.PlayerDataContext)
local ActionRail = require(ReplicatedStorage.UI.HUD.ActionRail)
local BottomDock = require(ReplicatedStorage.UI.HUD.BottomDock)
local LeftPanelColumn = require(ReplicatedStorage.UI.HUD.LeftPanelColumn)
local TopStatusBar = require(ReplicatedStorage.UI.HUD.TopStatusBar)
local ZoneProgressBar = require(ReplicatedStorage.UI.HUD.ZoneProgressBar)
local useResponsiveLayout = require(ReplicatedStorage.UI.Hooks.useResponsiveLayout)

export type Props = {
	quest: any?,
	factory: any?,
}

local EMPTY_FACTORY = {
	onToggleShop = nil,
	onSelectItem = nil,
}

local function point(x: number, y: number): UDim2
	return UDim2.fromOffset(x, y)
end

local function size(x: number, y: number): UDim2
	return UDim2.fromOffset(x, y)
end

local function region(position: UDim2, regionSize: UDim2, child: React.ReactNode): React.ReactNode
	return React.createElement("Frame", {
		Position = position,
		Size = regionSize,
		BackgroundTransparency = 1,
	}, {
		Content = React.createElement(React.Fragment, nil, child),
	})
end

local function MainHudScreen(props: Props)
	local responsive = useResponsiveLayout()
	local data = PlayerDataContext.usePlayerData()
	local factory = props.factory or EMPTY_FACTORY

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		DisplayOrder = Layout.DisplayOrder.HUD,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Canvas = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(Layout.ReferenceSize.X, Layout.ReferenceSize.Y),
			BackgroundTransparency = 1,
		}, {
			Scale = React.createElement("UIScale", {
				Scale = responsive.scale,
			}),
			TopStatusBar = region(
				point(380, 24),
				size(1490, 72),
				React.createElement(TopStatusBar, {
					gold = data.Gold,
					xp = data.XP,
				})
			),
			ZoneProgress = region(
				point(430, 116),
				size(1080, 76),
				React.createElement(ZoneProgressBar, { visible = true })
			),
			LeftColumn = region(
				point(22, 158),
				size(360, 680),
				React.createElement(LeftPanelColumn, { quest = props.quest })
			),
			RightRail = region(
				point(1590, 145),
				size(285, 540),
				React.createElement(ActionRail, { onBuild = factory.onToggleShop })
			),
			BottomDock = region(
				point(24, 885),
				size(1830, 150),
				React.createElement(BottomDock, {
					inventory = data.Factory.Inventory,
					onSelectItem = factory.onSelectItem,
				})
			),
		}),
	})
end

return MainHudScreen
