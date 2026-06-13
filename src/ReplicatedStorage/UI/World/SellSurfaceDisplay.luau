--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Typography = require(ReplicatedStorage.UI.Config.TypographyConfig)

local function SellSurfaceDisplay(props: { value: number })
	return React.createElement("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Typography.Heading.Font,
		Text = `${props.value}`,
		TextColor3 = Colors.World.SellSurface,
		TextScaled = true,
		TextWrapped = true,
	}, {
		SizeConstraint = React.createElement("UITextSizeConstraint", {
			MinTextSize = 1,
			MaxTextSize = 60,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Colors.World.SellSurfaceOutline,
			Thickness = 5,
			LineJoinMode = Enum.LineJoinMode.Round,
			Transparency = 0,
		}),
	})
end

return SellSurfaceDisplay
