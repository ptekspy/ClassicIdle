# Primitives

## Goal

Create the only modules allowed to directly render `UICorner`, `UIStroke`, `UIGradient`, `UIPadding`, typography labels, and icon images.

## Create `Corner.luau`

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)

local values: { [Types.CornerVariant]: number } = {
	Small = Layout.Radius.Small, Medium = Layout.Radius.Medium,
	Large = Layout.Radius.Large, Pill = Layout.Radius.Pill,
}

return function(props: { variant: Types.CornerVariant })
	return React.createElement("UICorner", { CornerRadius = UDim.new(0, assert(values[props.variant])) })
end
```

## Create `Stroke.luau`

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)

local styles: { [Types.StrokeVariant]: { color: Color3, thickness: number } } = {
	Outer = { color = Colors.Stroke.Outer, thickness = Layout.Stroke.Heavy },
	Blue = { color = Colors.Stroke.Blue, thickness = Layout.Stroke.Standard },
	Purple = { color = Colors.Stroke.Purple, thickness = Layout.Stroke.Standard },
}

return function(props: { variant: Types.StrokeVariant })
	local style = assert(styles[props.variant])
	return React.createElement("UIStroke", {
		Color = style.color, Thickness = style.thickness, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end
```

## Create `Gradient.luau`

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Gradients = require(ReplicatedStorage.UI.Config.GradientConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)

return function(props: { variant: Types.GradientVariant, rotation: number? })
	return React.createElement("UIGradient", {
		Color = assert(Gradients[props.variant]), Rotation = props.rotation or 90,
	})
end
```

## Create `Padding.luau`

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)

return function(props: { size: "XS" | "SM" | "MD" | "LG" | "XL" })
	local value = assert(Layout.Spacing[props.size])
	return React.createElement("UIPadding", {
		PaddingTop = UDim.new(0, value), PaddingBottom = UDim.new(0, value),
		PaddingLeft = UDim.new(0, value), PaddingRight = UDim.new(0, value),
	})
end
```

## Create `Text.luau`

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Typography = require(ReplicatedStorage.UI.Config.TypographyConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)

export type Props = {
	text: string, variant: Types.TextVariant, color: "Primary" | "Secondary" | "Yellow" | "Dark",
	size: UDim2, position: UDim2?, anchorPoint: Vector2?, textXAlignment: Enum.TextXAlignment?,
	textYAlignment: Enum.TextYAlignment?, wrapped: boolean?, layoutOrder: number?,
}

return function(props: Props)
	local style = assert(Typography[props.variant])
	return React.createElement("TextLabel", {
		Size = props.size, Position = props.position, AnchorPoint = props.anchorPoint,
		LayoutOrder = props.layoutOrder or 0, BackgroundTransparency = 1,
		Font = style.Font, TextSize = style.Size, Text = props.text,
		TextColor3 = assert(Colors.Text[props.color]), TextWrapped = props.wrapped == true,
		TextXAlignment = props.textXAlignment or Enum.TextXAlignment.Center,
		TextYAlignment = props.textYAlignment or Enum.TextYAlignment.Center,
		TextStrokeColor3 = Colors.Stroke.Outer, TextStrokeTransparency = 0.15,
	})
end
```

## Create `Icon.luau`

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Icons = require(ReplicatedStorage.UI.Config.IconConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)

local sizes: { [Types.IconSize]: number } = {
	Tiny = 18, Small = 28, Medium = 42, Large = 64, ActionTile = 76, Hero = 104,
}

return function(props: { icon: string, size: Types.IconSize, layoutOrder: number? })
	local definition = assert(Icons[props.icon], `Unknown icon: {props.icon}`)
	local pixels = assert(sizes[props.size])
	return React.createElement("ImageLabel", {
		LayoutOrder = props.layoutOrder or 0, Size = UDim2.fromOffset(pixels, pixels),
		BackgroundTransparency = 1, Image = definition.Asset, ScaleType = Enum.ScaleType.Fit,
	}, {
		Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = definition.AspectRatio }),
	})
end
```

## Rules

- Raw `Frame`, `ImageLabel`, `TextButton`, and layouts remain allowed when composing components.
- Raw corner, stroke, gradient, padding, tokenized text, and configured icon creation is forbidden outside primitives.

## Validation

Search outside `UI/Primitives` and `UI/Config`; these must return no new HUD matches:

```bash
rg 'Color3.fromRGB|Enum.Font.|createElement\\(\"UICorner|createElement\\(\"UIStroke|createElement\\(\"UIGradient' src/ReplicatedStorage/UI
```

## Done when

Every primitive renders independently and rejects unknown variants.
