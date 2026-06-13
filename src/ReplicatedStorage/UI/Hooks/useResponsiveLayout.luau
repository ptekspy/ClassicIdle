--!strict
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)

export type Result = { scale: number, viewportSize: Vector2 }

local function getGuiViewportSize(): Vector2
	local camera = workspace.CurrentCamera
	if not camera then
		return Layout.ReferenceSize
	end

	local topLeftInset, bottomRightInset = GuiService:GetGuiInset()
	local viewportSize = camera.ViewportSize

	return Vector2.new(
		math.max(1, viewportSize.X - topLeftInset.X - bottomRightInset.X),
		math.max(1, viewportSize.Y - topLeftInset.Y - bottomRightInset.Y)
	)
end

return function(): Result
	local size, setSize = React.useState(getGuiViewportSize())

	React.useEffect(function()
		local viewportConnection: RBXScriptConnection? = nil

		local function refresh()
			setSize(getGuiViewportSize())
		end

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

			refresh()

			viewportConnection = activeCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh)
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