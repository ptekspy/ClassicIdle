--!strict

local TweenService = game:GetService("TweenService")
local Types = require(script.Types)

local Local = {
	DROP_TRAVEL_SECONDS = 1.2,
	DROP_LIFETIME_SECONDS = 10,
}
local ResourceDropService = {}

function Local.getDropsFolder(plot: Model): Folder
	local drops = plot:FindFirstChild("Drops")

	if drops and drops:IsA("Folder") then
		return drops
	end

	local newDrops = Instance.new("Folder")
	newDrops.Name = "Drops"
	newDrops.Parent = plot

	return newDrops
end

function Local.getDropAppearance(resourceType: Types.ResourceType): (Vector3, Color3, Enum.Material)
	if resourceType == "Wood" then
		return Vector3.new(1.6, 0.8, 1), Color3.fromRGB(120, 72, 35), Enum.Material.Wood
	end

	if resourceType == "Stone" then
		return Vector3.new(1.2, 1.2, 1.2), Color3.fromRGB(100, 100, 100), Enum.Material.Slate
	end

	return Vector3.new(1.1, 1.1, 1.1), Color3.fromRGB(20, 20, 20), Enum.Material.Basalt
end

function ResourceDropService.SpawnDrop(options: Types.SpawnDropOptions)
	local size, color, material = Local.getDropAppearance(options.ResourceType)

	local drop = Instance.new("Part")
	drop.Name = `{options.ResourceType}Drop`
	drop.Size = size
	drop.Position = options.StartPosition
	drop.Anchored = true
	drop.CanCollide = false
	drop.Color = color
	drop.Material = material
	drop:SetAttribute("ResourceType", options.ResourceType)
	drop:SetAttribute("Amount", options.Amount)
	drop.Parent = Local.getDropsFolder(options.Plot)

	local collected = false

	local function collect()
		if collected then
			return
		end

		collected = true

		if drop.Parent then
			drop:Destroy()
		end

		options.OnCollected()
	end

	local randomOffset = Vector3.new(
		math.random(-15, 15) / 10,
		0,
		math.random(-15, 15) / 10
	)

	local tween = TweenService:Create(
		drop,
		TweenInfo.new(Local.DROP_TRAVEL_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			Position = options.EndPosition + randomOffset,
		}
	)

	tween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			collect()
		end
	end)

	tween:Play()

	task.delay(Local.DROP_LIFETIME_SECONDS, function()
		if drop.Parent then
			drop:Destroy()
		end
	end)
end


return ResourceDropService
