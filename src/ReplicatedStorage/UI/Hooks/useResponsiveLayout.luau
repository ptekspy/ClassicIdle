--!strict
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)

export type Result = {
	scale: number,
	viewportSize: Vector2,
	topLeftInset: Vector2,
	bottomRightInset: Vector2,
}

type Metrics = {
	viewportSize: Vector2,
	topLeftInset: Vector2,
	bottomRightInset: Vector2,
}

local function getMetrics(): Metrics
	local camera = workspace.CurrentCamera
	if not camera then
		return {
			viewportSize = Layout.ReferenceSize,
			topLeftInset = Vector2.new(0, 0),
			bottomRightInset = Vector2.new(0, 0),
		}
	end

	local topLeftInset, bottomRightInset = GuiService:GetGuiInset()
	local cameraViewportSize = camera.ViewportSize

	return {
		viewportSize = Vector2.new(
			math.max(1, cameraViewportSize.X - topLeftInset.X - bottomRightInset.X),
			math.max(1, cameraViewportSize.Y - topLeftInset.Y - bottomRightInset.Y)
		),
		topLeftInset = topLeftInset,
		bottomRightInset = bottomRightInset,
	}
end

return function(): Result
	local metrics, setMetrics = React.useState(getMetrics())

	React.useEffect(function()
		local viewportConnection: RBXScriptConnection? = nil

		local function refresh()
			setMetrics(getMetrics())
		end

		local function connectCamera()
			if viewportConnection then
				viewportConnection:Disconnect()
				viewportConnection = nil
			end

			local activeCamera = workspace.CurrentCamera
			if not activeCamera then
				setMetrics(getMetrics())
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
		scale = math.min(metrics.viewportSize.X / Layout.ReferenceSize.X, metrics.viewportSize.Y / Layout.ReferenceSize.Y),
		viewportSize = metrics.viewportSize,
		topLeftInset = metrics.topLeftInset,
		bottomRightInset = metrics.bottomRightInset,
	}
end