--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local ActionButton = require(script.Parent.ActionButton)

local function MachineMenuContent(props: { menu: any })
	local menu = props.menu
	local payload = menu.payload
	local children = {}

	if payload.Kind == "Processor" then
		children.Processing = React.createElement(ActionButton, {
			height = 72,
			layoutOrder = 1,
			text = `Upgrade Processing Time\n{payload.ProcessingTime}s -> {payload.NextProcessingTime}s | {payload.ProcessingTimeCost} Gold`,
			onActivated = function()
				menu.onUpgrade(payload.PartId, "ProcessingTime")
			end,
		})
		children.Multiplier = React.createElement(ActionButton, {
			height = 72,
			layoutOrder = 2,
			text = `Upgrade Output Multiplier\nx{payload.OutputMultiplier} -> x{payload.NextOutputMultiplier} | {payload.OutputMultiplierCost} Gold`,
			onActivated = function()
				menu.onUpgrade(payload.PartId, "OutputMultiplier")
			end,
		})
	elseif payload.Upgradeable then
		if payload.PartId == "CollectionPoint" then
			children.Collect = React.createElement(ActionButton, {
				height = 72,
				layoutOrder = 1,
				text = "Collect Stored Coal",
				onActivated = function()
					menu.onCollect(payload.PartId)
				end,
			})
		end
		children.Upgrade = React.createElement(ActionButton, {
			height = 72,
			layoutOrder = 2,
			text = `Upgrade {payload.StatName}\n{payload.CurrentValue} -> {payload.NextValue} | {payload.UpgradeCost} Gold`,
			onActivated = function()
				menu.onUpgrade(payload.PartId, "Level")
			end,
		})
	end

	return React.createElement(React.Fragment, nil, children)
end

return MachineMenuContent