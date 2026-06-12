--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local ActionButton = require(script.Parent.ActionButton)

local function WorkerMenuContent(props: { menu: any })
	local menu = props.menu
	local payload = menu.payload
	local children = {}

	if payload.Kind == "Purchase" then
		for index, role in payload.Roles do
			local enabled = role.Unlocked == true
			children[`Role{index}`] = React.createElement(ActionButton, {
				text = if enabled then `{role.DisplayName}\nCost: {role.Cost} Gold` else `{role.DisplayName}\nLocked`,
				enabled = enabled,
				layoutOrder = index,
				onActivated = function()
					menu.onBuy(role.Role)
				end,
			})
		end
	elseif payload.Kind == "Manage" then
		local cargo = if payload.CargoAmount > 0 then `{payload.CargoAmount} {payload.CargoType}` else "Empty"
		children.Cargo = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 46),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = `Current cargo: {cargo}`,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 18,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		children.Speed = React.createElement(ActionButton, {
			text = `Upgrade Speed\n{payload.Speed} → {payload.Speed + 2} • {payload.SpeedCost} Gold`,
			layoutOrder = 2,
			onActivated = function()
				menu.onUpgrade(payload.NPCId, "Speed")
			end,
		})
		children.Amount = React.createElement(ActionButton, {
			text = `Upgrade Amount\n{payload.Amount} → {payload.Amount + 1} • {payload.AmountCost} Gold`,
			layoutOrder = 3,
			onActivated = function()
				menu.onUpgrade(payload.NPCId, "Amount")
			end,
		})
	end

	return React.createElement(React.Fragment, nil, children)
end

return WorkerMenuContent