--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)
local Corner = require(ReplicatedStorage.UI.Primitives.Corner)
local Gradient = require(ReplicatedStorage.UI.Primitives.Gradient)
local Stroke = require(ReplicatedStorage.UI.Primitives.Stroke)

export type Props = {
	variant: Types.PanelVariant,
	size: UDim2,
	position: UDim2?,
	anchorPoint: Vector2?,
	layoutOrder: number?,
	children: React.ReactNode,
}

type Style = {
	color: Color3,
	gradient: Types.GradientVariant,
	stroke: Types.StrokeVariant,
}

local styles: { [Types.PanelVariant]: Style } = {
	Standard = { color = Colors.Panel.Primary, gradient = "PanelBlue", stroke = "Blue" },
	Quest = { color = Colors.Panel.Secondary, gradient = "PanelBlue", stroke = "Blue" },
	Event = { color = Colors.Panel.Event, gradient = "PanelPurple", stroke = "Purple" },
	Status = { color = Colors.Panel.Deep, gradient = "PanelBlue", stroke = "Blue" },
}

local function Panel(props: Props)
	local style = assert(styles[props.variant], `Unknown panel variant: {props.variant}`)

	return React.createElement("Frame", {
		Size = props.size,
		Position = props.position,
		AnchorPoint = props.anchorPoint,
		LayoutOrder = props.layoutOrder or 0,
		BackgroundColor3 = style.color,
	}, {
		Corner = React.createElement(Corner, { variant = "Large" }),
		Stroke = React.createElement(Stroke, { variant = style.stroke }),
		Gradient = React.createElement(Gradient, { variant = style.gradient }),
		Content = React.createElement(React.Fragment, nil, props.children),
	})
end

return Panel
