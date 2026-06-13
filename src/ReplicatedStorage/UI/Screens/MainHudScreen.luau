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

local function scaled(value: number, scale: number): number
	return math.floor(value * scale + 0.5)
end

local function region(
	anchorPoint: Vector2,
	position: Vector2,
	regionSize: Vector2,
	scale: number,
	child: React.ReactNode
): React.ReactNode
	local safeScale = math.max(scale, 0.01)

	return React.createElement("Frame", {
		AnchorPoint = anchorPoint,
		Position = UDim2.fromOffset(position.X, position.Y),
		Size = UDim2.fromOffset(regionSize.X, regionSize.Y),
		BackgroundTransparency = 1,
	}, {
		Content = React.createElement("Frame", {
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromOffset(regionSize.X / safeScale, regionSize.Y / safeScale),
			BackgroundTransparency = 1,
		}, {
			Scale = React.createElement("UIScale", {
				Scale = safeScale,
			}),
			Child = React.createElement(React.Fragment, nil, child),
		}),
	})
end

local function MainHudScreen(props: Props)
	local responsive = useResponsiveLayout()
	local data = PlayerDataContext.usePlayerData()
	local factory = props.factory or EMPTY_FACTORY

	local scale = math.max(responsive.scale, 0.01)
	local screenWidth = math.max(1, responsive.viewportSize.X)
	local screenHeight = math.max(1, responsive.viewportSize.Y)

	local function s(value: number): number
		return scaled(value, scale)
	end

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		DisplayOrder = Layout.DisplayOrder.HUD,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Canvas = React.createElement("Frame", {
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			TopStatusBar = region(
				Vector2.new(0, 0),
				Vector2.new(s(380), s(24)),
				Vector2.new(math.max(1, screenWidth - s(430)), s(72)),
				scale,
				React.createElement(TopStatusBar, {
					gold = data.Gold,
					xp = data.XP,
				})
			),

			ZoneProgress = region(
				Vector2.new(0, 0),
				Vector2.new(s(430), s(116)),
				Vector2.new(math.max(1, screenWidth - s(840)), s(76)),
				scale,
				React.createElement(ZoneProgressBar, {
					visible = true,
				})
			),

			LeftColumn = region(
				Vector2.new(0, 0),
				Vector2.new(s(22), s(158)),
				Vector2.new(s(360), s(680)),
				scale,
				React.createElement(LeftPanelColumn, {
					quest = props.quest,
				})
			),

			RightRail = region(
				Vector2.new(1, 0),
				Vector2.new(screenWidth - s(45), s(145)),
				Vector2.new(s(285), s(540)),
				scale,
				React.createElement(ActionRail, {
					onBuild = factory.onToggleShop,
				})
			),

			BottomDock = region(
				Vector2.new(0, 1),
				Vector2.new(s(24), screenHeight - s(45)),
				Vector2.new(math.max(1, screenWidth - s(90)), s(150)),
				scale,
				React.createElement(BottomDock, {
					inventory = data.Factory.Inventory,
					onSelectItem = factory.onSelectItem,
				})
			),
		}),
	})
end

return MainHudScreen