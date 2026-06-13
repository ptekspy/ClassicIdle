--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Typography = require(ReplicatedStorage.UI.Config.TypographyConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)

export type Props = {
	text: string,
	variant: Types.TextVariant,
	color: "Primary" | "Secondary" | "Yellow" | "Dark",
	size: UDim2,
	position: UDim2?,
	anchorPoint: Vector2?,
	textXAlignment: Enum.TextXAlignment?,
	textYAlignment: Enum.TextYAlignment?,
	wrapped: boolean?,
	layoutOrder: number?,
}

return function(props: Props)
	local style = assert(Typography[props.variant], `Unknown text variant: {props.variant}`)
	return React.createElement("TextLabel", {
		Size = props.size,
		Position = props.position,
		AnchorPoint = props.anchorPoint,
		LayoutOrder = props.layoutOrder or 0,
		BackgroundTransparency = 1,
		Font = style.Font,
		TextSize = style.Size,
		Text = props.text,
		TextColor3 = assert(Colors.Text[props.color], `Unknown text color: {props.color}`),
		TextWrapped = props.wrapped == true,
		TextXAlignment = props.textXAlignment or Enum.TextXAlignment.Center,
		TextYAlignment = props.textYAlignment or Enum.TextYAlignment.Center,
		TextStrokeColor3 = Colors.Stroke.Outer,
		TextStrokeTransparency = 0.15,
	})
end
