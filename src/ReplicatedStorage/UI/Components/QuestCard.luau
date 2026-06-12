--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	title: string,
	description: string,
	progressText: string,
	visible: boolean,
}

local function QuestCard(props: Props)
	return React.createElement("Frame", {
		Name = "QuestCard",
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.new(0.38, 0, 0, 150),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.08,
		Visible = props.visible,
	}, {
		Constraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(280, 150),
			MaxSize = Vector2.new(460, 150),
		}),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 14),
		}),
		Heading = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(16, 10),
			Size = UDim2.new(1, -32, 0, 22),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = "CURRENT QUEST",
			TextColor3 = Color3.fromRGB(110, 215, 125),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Title = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(16, 32),
			Size = UDim2.new(1, -32, 0, 30),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = props.title,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 21,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Description = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(16, 64),
			Size = UDim2.new(1, -32, 0, 42),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = props.description,
			TextColor3 = Color3.fromRGB(215, 215, 215),
			TextSize = 15,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}),
		Progress = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(16, 112),
			Size = UDim2.new(1, -32, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = props.progressText,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
end

return QuestCard