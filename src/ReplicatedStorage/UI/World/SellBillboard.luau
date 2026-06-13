--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Typography = require(ReplicatedStorage.UI.Config.TypographyConfig)

local richTextOutline = Colors.World.SellBillboardRichTextOutline
local outlineRichText = `rgb({math.round(richTextOutline.R * 255)}, {math.round(richTextOutline.G * 255)}, {math.round(
	richTextOutline.B * 255
)})`

local function SellBillboard(props: { value: number })
	return React.createElement("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Typography.Heading.Font,
		RichText = true,
		Text = `<stroke color="{outlineRichText}" joins="miter" thickness="7" transparency="0.5">${props.value}</stroke>`,
		TextColor3 = Colors.World.SellBillboard,
		TextScaled = true,
		TextStrokeColor3 = Colors.World.SellBillboardOutline,
		TextStrokeTransparency = 0,
		TextWrapped = true,
	})
end

return SellBillboard
