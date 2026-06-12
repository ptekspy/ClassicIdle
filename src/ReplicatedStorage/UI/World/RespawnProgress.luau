--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function RespawnProgress(props: { progress: number })
	return React.createElement("Frame", {
		Name = "Background",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		Fill = React.createElement("Frame", {
			Name = "Fill",
			Size = UDim2.fromScale(math.clamp(props.progress, 0, 1), 1),
			BackgroundColor3 = Color3.fromRGB(95, 220, 110),
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

return RespawnProgress