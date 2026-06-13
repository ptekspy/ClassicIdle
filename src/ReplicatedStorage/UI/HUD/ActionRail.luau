--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local HUD = require(ReplicatedStorage.UI.Config.HUDConfig)
local ActionTile = require(ReplicatedStorage.UI.Components.ActionTile)

export type Props = {
	onBuild: (() -> ())?,
}

local function tile(
	label: string,
	icon: string,
	badge: string?,
	layoutOrder: number,
	onActivated: (() -> ())?
): React.ReactNode
	return React.createElement(ActionTile, {
		label = label,
		icon = icon,
		badge = badge,
		layoutOrder = layoutOrder,
		onActivated = onActivated,
	})
end

local function ActionRail(props: Props)
	local children: { [string]: React.ReactNode } = {
		Grid = React.createElement("UIGridLayout", {
			CellSize = UDim2.fromOffset(116, 126),
			CellPadding = UDim2.fromOffset(18, 12),
			FillDirection = Enum.FillDirection.Horizontal,
			FillDirectionMaxCells = 2,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),
		Shop = tile("Shop", "Shop", "!", 1, nil),
		Build = tile("Build", "Build", "!", 2, props.onBuild),
		Rocket = tile("Rocket", "Rocket", "!", 3, nil),
		Pets = tile("Pets", "Pets", tostring(HUD.Demo.PetsBadge), 4, nil),
		Worlds = tile("Worlds", "Worlds", nil, 5, nil),
		Rebirth = tile("Rebirth", "Rebirth", "!", 6, nil),
		Codes = tile("Codes", "Codes", nil, 7, nil),
		Settings = tile("Settings", "Settings", nil, 8, nil),
	}

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, children)
end

return ActionRail
