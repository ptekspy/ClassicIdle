--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function SellSurfaceDisplay(props: { value: number })
	return React.createElement("TextLabel", {
		Name = "TextLabel",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = `${props.value}`,
		TextColor3 = Color3.fromRGB(0, 255, 0),
		TextScaled = true,
		TextWrapped = true,
	}, {
		SizeConstraint = React.createElement("UITextSizeConstraint", {
			MinTextSize = 1,
			MaxTextSize = 60,
		}),
		Stroke = React.createElement("UIStroke", {
			Color = Color3.fromRGB(0, 116, 0),
			Thickness = 5,
			LineJoinMode = Enum.LineJoinMode.Round,
			Transparency = 0,
		}),
	})
end

return SellSurfaceDisplay