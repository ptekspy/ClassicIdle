--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)
local Crosshair = require(script.Parent.Parent.Components.Crosshair)
local InteractionPrompt = require(script.Parent.Parent.Components.InteractionPrompt)
local TouchInteractButton = require(script.Parent.Parent.Components.TouchInteractButton)

local EMPTY = {
	visible = false,
	actionText = "",
	objectText = "",
	inputHint = "",
	inputMode = "MouseKeyboard",
	onActivated = function() end,
}

local function InteractionScreen(props: { interaction: any? })
	local state = props.interaction or EMPTY

	return React.createElement("ScreenGui", {
		DisplayOrder = Layout.DisplayOrder.Interaction,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Prompt = React.createElement(InteractionPrompt, {
			actionText = state.actionText,
			objectText = state.objectText,
			inputHint = state.inputHint,
			visible = state.visible,
		}),
		TouchButton = React.createElement(TouchInteractButton, {
			visible = state.visible and state.inputMode == "Touch",
			onActivated = state.onActivated,
		}),
		Crosshair = React.createElement(Crosshair, {
			visible = state.inputMode ~= "MouseKeyboard",
		}),
	})
end

return InteractionScreen
