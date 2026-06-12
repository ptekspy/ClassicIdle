# Responsive Reference Canvas

## Goal

Preserve the reference at `1920x1080` while adapting safely to smaller viewports.

## Create `useResponsiveLayout.luau`

```luau
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
		return function() connection:Disconnect() end
	end, {})

	local mode
	if size.X >= Layout.Breakpoint.Desktop then mode = "Desktop"
	elseif size.X >= Layout.Breakpoint.Tablet then mode = "Tablet"
	elseif size.X >= size.Y then mode = "LandscapePhone"
	else mode = "PortraitPhone" end

	return { mode = mode, scale = math.min(size.X / 1920, size.Y / 1080) }
end
```

## Create the canvas in `MainHudScreen`

Render a full-screen transparent frame. Inside it, render five named region frames:

| Region | Reference position | Reference size |
|---|---:|---:|
| TopStatusBar | `(380, 24)` | `(1490, 72)` |
| ZoneProgress | `(430, 116)` | `(1080, 76)` |
| LeftColumn | `(22, 158)` | `(360, 680)` |
| RightRail | `(1590, 145)` | `(285, 540)` |
| BottomDock | `(24, 885)` | `(1830, 150)` |

Convert reference values to scale:

```luau
local function point(x: number, y: number): UDim2
	return UDim2.fromScale(x / 1920, y / 1080)
end

local function size(x: number, y: number): UDim2
	return UDim2.fromScale(x / 1920, y / 1080)
end
```

Add a `UIScale` to each complete region using `responsive.scale`, not to individual children.

## Mode behavior

- Desktop: show all regions.
- Tablet: scale regions to `math.max(scale, 0.72)` and reduce external gaps.
- LandscapePhone: hide Daily Reward, Limited Event, Invite Friends, and disabled rail tiles; keep quest, Build, hotbar, and Launch.
- PortraitPhone: show top Gold/Level, quest, Build, hotbar, and interaction UI; hide all disabled regions.

## Safe areas

- ScreenGui uses `IgnoreGuiInset = false`.
- Do not place functional controls beneath Roblox core buttons.
- Keep every functional touch target at least `44x44`.

## Done when

Desktop matches the reference and no functional control overlaps or becomes untappable at supported sizes.
