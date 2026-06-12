--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)

export type Result = { mode: "Desktop" | "Tablet" | "LandscapePhone" | "PortraitPhone", scale: number }

return function(): Result
	local camera = workspace.CurrentCamera
	local size, setSize = React.useState(if camera then camera.ViewportSize else Layout.ReferenceSize)

	React.useEffect(function()
		local activeCamera = workspace.CurrentCamera
		if not activeCamera then return end
		setSize(activeCamera.ViewportSize)
		local connection = activeCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			setSize(activeCamera.ViewportSize)
		end)
		return function() 
            connection:Disconnect() 
        end
	end, {})

	local mode
	if size.X >= Layout.Breakpoint.Desktop then mode = "Desktop"
	elseif size.X >= Layout.Breakpoint.Tablet then mode = "Tablet"
	elseif size.X >= size.Y then mode = "LandscapePhone"
	else mode = "PortraitPhone" end

	return { mode = mode, scale = math.min(size.X / 1920, size.Y / 1080) }
end