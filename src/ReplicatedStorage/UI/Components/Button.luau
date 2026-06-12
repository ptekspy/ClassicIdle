--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)
local useButtonState = require(ReplicatedStorage.UI.Hooks.useButtonState)
local Corner = require(ReplicatedStorage.UI.Primitives.Corner)
local Gradient = require(ReplicatedStorage.UI.Primitives.Gradient)
local Stroke = require(ReplicatedStorage.UI.Primitives.Stroke)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	text: string,
	variant: Types.ButtonVariant,
	size: UDim2,
	layoutOrder: number?,
	onActivated: (() -> ())?,
}

type Style = {
	color: Color3,
	gradient: Types.GradientVariant,
	textColor: "Primary" | "Secondary" | "Yellow" | "Dark",
}

local styles: { [Types.ButtonVariant]: Style } = {
	Primary = { color = Colors.Button.Blue, gradient = "PanelBlue", textColor = "Primary" },
	Secondary = { color = Colors.Panel.Event, gradient = "PanelPurple", textColor = "Primary" },
	GreenHero = { color = Colors.Button.Green, gradient = "ButtonGreen", textColor = "Dark" },
	Disabled = { color = Colors.Button.Disabled, gradient = "ButtonDisabled", textColor = "Secondary" },
}

local function isPressInput(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
		or input.KeyCode == Enum.KeyCode.ButtonA
end

local function Button(props: Props)
	local enabled = props.onActivated ~= nil and props.variant ~= "Disabled"
	local state = useButtonState(enabled)
	local style = assert(styles[props.variant], `Unknown button variant: {props.variant}`)
	local scale = if state.pressed then 0.96 elseif state.hovered or state.selected then 1.03 else 1

	return React.createElement("TextButton", {
		Size = props.size,
		LayoutOrder = props.layoutOrder or 0,
		BackgroundColor3 = style.color,
		Text = "",
		Active = enabled,
		Selectable = enabled,
		AutoButtonColor = false,
		[React.Event.Activated] = if enabled then props.onActivated else nil,
		[React.Event.MouseEnter] = state.onEnter,
		[React.Event.MouseLeave] = state.onLeave,
		[React.Event.SelectionGained] = state.onSelect,
		[React.Event.SelectionLost] = state.onDeselect,
		[React.Event.InputBegan] = if enabled
			then function(_instance: GuiObject, input: InputObject)
				if isPressInput(input) and state.onDown then
					state.onDown()
				end
			end
			else nil,
		[React.Event.InputEnded] = if enabled
			then function(_instance: GuiObject, input: InputObject)
				if isPressInput(input) and state.onUp then
					state.onUp()
				end
			end
			else nil,
	}, {
		Scale = React.createElement("UIScale", { Scale = scale }),
		Corner = React.createElement(Corner, { variant = "Medium" }),
		Stroke = React.createElement(Stroke, { variant = "Outer" }),
		Gradient = React.createElement(Gradient, { variant = style.gradient }),
		Label = React.createElement(Text, {
			text = props.text,
			variant = if props.variant == "GreenHero" then "Heading" else "Label",
			color = style.textColor,
			size = UDim2.fromScale(1, 1),
			wrapped = true,
		}),
	})
end

return Button
