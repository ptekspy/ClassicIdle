--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	actionText: string,
	objectText: string,
	inputHint: string,
	visible: boolean,
}

local function InteractionPrompt(props: Props)
	return React.createElement("Frame", {
		Name = "Prompt",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.92),
		Size = UDim2.new(0.8, 0, 0, 82),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.12,
		Visible = props.visible,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(440, 82),
			MinSize = Vector2.new(240, 82),
		}),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Action = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(18, 8),
			Size = UDim2.new(1, -110, 0, 32),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = props.actionText,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 21,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Object = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(18, 40),
			Size = UDim2.new(1, -110, 0, 28),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = props.objectText,
			TextColor3 = Color3.fromRGB(205, 205, 205),
			TextSize = 16,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		InputHint = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -16, 0.5, 0),
			Size = UDim2.fromOffset(72, 48),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBold,
			Text = props.inputHint,
			TextColor3 = Color3.fromRGB(25, 25, 25),
			TextSize = 16,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
		}),
	})
end

return InteractionPrompt