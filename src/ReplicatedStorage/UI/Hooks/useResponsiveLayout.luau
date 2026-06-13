--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)

export type Result = { scale: number, viewportSize: Vector2 }

return function(): Result
	local camera = workspace.CurrentCamera
	local size, setSize = React.useState(if camera then camera.ViewportSize else Layout.ReferenceSize)

	React.useEffect(function()
		local viewportConnection: RBXScriptConnection? = nil

		local function connectCamera()
			if viewportConnection then
				viewportConnection:Disconnect()
				viewportConnection = nil
			end

			local activeCamera = workspace.CurrentCamera
			if not activeCamera then
				setSize(Layout.ReferenceSize)
				return
			end

			setSize(activeCamera.ViewportSize)
			viewportConnection = activeCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				setSize(activeCamera.ViewportSize)
			end)
		end

		connectCamera()
		local cameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectCamera)

		return function()
			cameraConnection:Disconnect()
			if viewportConnection then
				viewportConnection:Disconnect()
			end
		end
	end, {})

	return {
		scale = math.min(size.X / Layout.ReferenceSize.X, size.Y / Layout.ReferenceSize.Y),
		viewportSize = size,
	}
end
