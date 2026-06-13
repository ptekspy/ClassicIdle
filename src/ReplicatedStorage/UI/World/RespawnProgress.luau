--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Corner = require(ReplicatedStorage.UI.Primitives.Corner)

local function RespawnProgress(props: { progress: number })
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Colors.World.Background,
	}, {
		Corner = React.createElement(Corner, { variant = "Small" }),
		Fill = React.createElement("Frame", {
			Size = UDim2.fromScale(math.clamp(props.progress, 0, 1), 1),
			BackgroundColor3 = Colors.World.RespawnFill,
		}, {
			Corner = React.createElement(Corner, { variant = "Small" }),
		}),
	})
end

return RespawnProgress
