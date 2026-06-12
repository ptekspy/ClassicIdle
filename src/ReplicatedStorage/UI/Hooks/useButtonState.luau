--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

return function(enabled: boolean)
	local hovered, setHovered = React.useState(false)
	local pressed, setPressed = React.useState(false)
	local selected, setSelected = React.useState(false)

	React.useEffect(function()
		if not enabled then
			setHovered(false)
			setPressed(false)
			setSelected(false)
		end
	end, { enabled })

	return {
		hovered = hovered,
		pressed = pressed,
		selected = selected,
		onEnter = if enabled
			then function()
				setHovered(true)
			end
			else nil,
		onLeave = if enabled
			then function()
				setHovered(false)
				setPressed(false)
			end
			else nil,
		onDown = if enabled
			then function()
				setPressed(true)
			end
			else nil,
		onUp = if enabled
			then function()
				setPressed(false)
			end
			else nil,
		onSelect = if enabled
			then function()
				setSelected(true)
			end
			else nil,
		onDeselect = if enabled
			then function()
				setSelected(false)
				setPressed(false)
			end
			else nil,
	}
end
