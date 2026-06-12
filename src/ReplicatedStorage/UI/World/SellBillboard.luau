--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function SellBillboard(props: { value: number })
	return React.createElement("TextLabel", {
		Name = "TextLabel",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		RichText = true,
		Text = `<stroke color="rgb(0, 118, 0)" joins="miter" thickness="7" transparency="0.5">${props.value}</stroke>`,
		TextColor3 = Color3.fromRGB(85, 255, 0),
		TextScaled = true,
		TextStrokeColor3 = Color3.fromRGB(0, 138, 0),
		TextStrokeTransparency = 0,
		TextWrapped = true,
	})
end

return SellBillboard