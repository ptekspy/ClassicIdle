--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)
local ModalPanel = require(script.Parent.Parent.Components.ModalPanel)
local WorkerMenuContent = require(script.Parent.Parent.Components.WorkerMenuContent)

local function WorkerScreen(props: { menu: any? })
	local menu = props.menu
	local title = if menu and menu.payload.Kind == "Purchase"
		then "Hire NPC"
		else if menu then menu.payload.DisplayName else ""

	return React.createElement("ScreenGui", {
		DisplayOrder = Layout.DisplayOrder.Overlay,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Modal = React.createElement(
			ModalPanel,
			{
				title = title,
				visible = menu ~= nil,
				onClose = if menu then menu.onClose else function() end,
			},
			if menu
				then {
					Content = React.createElement(WorkerMenuContent, { menu = menu }),
				}
				else nil
		),
	})
end

return WorkerScreen
