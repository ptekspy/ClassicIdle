--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local FeedbackToast = require(script.Parent.Parent.Components.FeedbackToast)

export type FeedbackState = {
	id: number,
	message: string,
	onFinished: (number) -> (),
}

export type Props = {
	feedback: FeedbackState?,
}

local function FeedbackScreen(props: Props)
	local children = {}
	if props.feedback then
		children.Toast = React.createElement(FeedbackToast, {
			message = props.feedback.message,
			messageId = props.feedback.id,
			onFinished = props.feedback.onFinished,
		})
	end

	return React.createElement("ScreenGui", {
		Name = "FeedbackGui",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 10,
	}, children)
end

return FeedbackScreen
