--!strict

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local PlotConfig = require(ReplicatedStorage.Plot.Config)
local Types = require(script.Types)
local resolve = require(ReplicatedStorage.Plot.resolve)

local Local = {
	DROP_TRAVEL_SECONDS = 1.2,
	DROP_LIFETIME_SECONDS = 10,
}
local ResourceDropService = {}

function Local.getDropsFolder(plot: Model): Folder
	local drops = resolve(plot, PlotConfig.Paths.Drops)

	if drops and drops:IsA("Folder") then
		return drops
	end

	local newDrops = Instance.new("Folder")
	newDrops.Name = "Drops"
	local old = plot:FindFirstChild("OLD")
	newDrops.Parent = old or plot

	return newDrops
end

function Local.getDropAppearance(resourceType: Types.ResourceType): (Vector3, Color3, Enum.Material)
	local definition = ResourceConfig.Get(resourceType)
	local appearance = definition and definition.DropAppearance
	if appearance then
		return appearance.Size, appearance.Color, appearance.Material
	end
	return Vector3.one, Color3.fromRGB(255, 0, 255), Enum.Material.SmoothPlastic
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
