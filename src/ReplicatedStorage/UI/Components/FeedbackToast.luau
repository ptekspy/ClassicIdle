--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	message: string,
	messageId: number,
	onFinished: (number) -> (),
}

local function FeedbackToast(props: Props)
	local labelRef = React.useRef(nil :: TextLabel?)

	React.useEffect(function()
		local label = labelRef.current
		if not label then
			return
		end

		label.Position = UDim2.fromScale(0.5, 0.88)
		label.BackgroundTransparency = 1
		label.TextTransparency = 1

		local active = true
		local hideTween: Tween? = nil
		local showTween = TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.15,
			Position = UDim2.fromScale(0.5, 0.82),
			TextTransparency = 0,
		})
		showTween:Play()

		task.spawn(function()
			showTween.Completed:Wait()
			task.wait(1.8)
			if not active then
				return
			end

			hideTween = TweenService:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.77),
				TextTransparency = 1,
			})
			hideTween:Play()
			hideTween.Completed:Wait()

			if active then
				props.onFinished(props.messageId)
			end
		end)

		return function()
			active = false
			showTween:Cancel()
			if hideTween then
				hideTween:Cancel()
			end
		end
	end, { props.messageId })

	return React.createElement("TextLabel", {
		Name = "Feedback",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.88),
		Size = UDim2.new(0.85, 0, 0, 60),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = props.message,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 22,
		TextTransparency = 1,
		TextWrapped = true,
		ref = labelRef,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(420, 60),
			MinSize = Vector2.new(220, 60),
		}),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
	})
end

return FeedbackToast
