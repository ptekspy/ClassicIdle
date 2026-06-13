--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Typography = require(ReplicatedStorage.UI.Config.TypographyConfig)
local Corner = require(ReplicatedStorage.UI.Primitives.Corner)

local function WorldLabel(props: { text: string })
	return React.createElement("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Colors.World.Background,
		BackgroundTransparency = 0.2,
		Text = props.text,
		TextColor3 = Colors.Text.Primary,
		TextScaled = true,
		TextWrapped = true,
		Font = Typography.Heading.Font,
	}, {
		Corner = React.createElement(Corner, { variant = "Small" }),
	})
end

return WorldLabel
