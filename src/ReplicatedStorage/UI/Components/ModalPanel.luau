--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	title: string,
	visible: boolean,
	onClose: () -> (),
	children: React.ReactNode,
}

local function ModalPanel(props: Props)
	return React.createElement("Frame", {
		Name = "Shade",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		Visible = props.visible,
	}, {
		Panel = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.85, 0, 0, 390),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		}, {
			Constraint = React.createElement("UISizeConstraint", {
				MinSize = Vector2.new(300, 390),
				MaxSize = Vector2.new(520, 390),
			}),
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 14),
			}),
			Title = React.createElement("TextLabel", {
				Position = UDim2.fromOffset(20, 14),
				Size = UDim2.new(1, -80, 0, 42),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Text = props.title,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 25,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			Close = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -14, 0, 14),
				Size = UDim2.fromOffset(42, 42),
				BackgroundColor3 = Color3.fromRGB(55, 55, 55),
				Font = Enum.Font.GothamBold,
				Text = "X",
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 18,
				[React.Event.Activated] = props.onClose,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 10),
				}),
			}),
			Content = React.createElement("Frame", {
				Position = UDim2.fromOffset(20, 68),
				Size = UDim2.new(1, -40, 1, -88),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					Padding = UDim.new(0, 10),
				}),
				Body = React.createElement(React.Fragment, nil, props.children),
			}),
		}),
	})
end

return ModalPanel