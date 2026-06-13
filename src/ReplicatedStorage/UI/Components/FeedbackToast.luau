--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Vendor.React)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	message: string,
	messageId: number,
	onFinished: (number) -> (),
}

local function FeedbackToast(props: Props)
	local groupRef = React.useRef(nil :: CanvasGroup?)

	React.useEffect(function()
		local group = groupRef.current
		if not group then
			return
		end

		group.Position = UDim2.fromScale(0.5, 0.88)
		group.GroupTransparency = 1

		local active = true
		local hideTween: Tween? = nil
		local showTween =
			TweenService:Create(group, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				GroupTransparency = 0,
				Position = UDim2.fromScale(0.5, 0.82),
			})
		showTween:Play()

		task.spawn(function()
			showTween.Completed:Wait()
			task.wait(1.8)
			if not active then
				return
			end

			hideTween =
				TweenService:Create(group, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					GroupTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.77),
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

	return React.createElement("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.88),
		Size = UDim2.new(0.85, 0, 0, 60),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		ref = groupRef,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(420, 60),
			MinSize = Vector2.new(220, 60),
		}),
		Panel = React.createElement(Panel, {
			variant = "Status",
			size = UDim2.fromScale(1, 1),
			children = {
				Message = React.createElement(Text, {
					text = props.message,
					variant = "Heading",
					color = "Primary",
					size = UDim2.fromScale(1, 1),
					wrapped = true,
				}),
			},
		}),
	})
end

return FeedbackToast
