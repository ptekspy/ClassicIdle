--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local MachineMenuContent = require(script.Parent.Parent.Components.MachineMenuContent)
local ModalPanel = require(script.Parent.Parent.Components.ModalPanel)

local function MachineScreen(props: { menu: any? })
	local menu = props.menu

	return React.createElement("ScreenGui", {
		Name = "MachineGui",
		DisplayOrder = 30,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Modal = React.createElement(ModalPanel, {
			title = if menu then menu.payload.DisplayName else "",
			visible = menu ~= nil,
			onClose = if menu then menu.onClose else function() end,
		}, if menu then {
			Content = React.createElement(MachineMenuContent, { menu = menu }),
		} else nil),
	})
end

return MachineScreen