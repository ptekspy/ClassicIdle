--!strict

local Types = require(script.Parent.Types)

local Config = {
	Order = {
		"Wood",
		"Stone",
		"Coal",
	} :: { Types.ResourceId },
	Definitions = {
		Wood = {
			DisplayName = "Wood",
			SellPrice = 1,
			ShowInLeaderstats = true,
			FactoryEnabled = true,
			Worker = {
				DisplayName = "Wood NPC",
				BaseCost = 10,
				TemplateName = "Wood",
				ActionAnimationId = "rbxassetid://522635514",
				Behavior = "ResourceNode",
				Unlock = nil,
			},
			ManualCollection = {
				Enabled = true,
				ActionText = "Chop",
				ObjectText = "Tree",
				Amount = 1,
				Unlock = nil,
			},
			DropAppearance = {
				Size = Vector3.new(1.6, 0.8, 1),
				Color = Color3.fromRGB(120, 72, 35),
				Material = Enum.Material.Wood,
			},
		},
		Stone = {
			DisplayName = "Stone",
			SellPrice = 3,
			ShowInLeaderstats = true,
			FactoryEnabled = true,
			Worker = {
				DisplayName = "Stone NPC",
				BaseCost = 25,
				TemplateName = "Stone",
				ActionAnimationId = "rbxassetid://522635514",
				Behavior = "ResourceNode",
				Unlock = "RequiresWorker:Wood",
			},
			ManualCollection = {
				Enabled = true,
				ActionText = "Mine",
				ObjectText = "Rock",
				Amount = 1,
				Unlock = "RequiresWorker:Wood",
			},
			DropAppearance = {
				Size = Vector3.new(1.2, 1.2, 1.2),
				Color = Color3.fromRGB(100, 100, 100),
				Material = Enum.Material.Slate,
			},
		},
		Coal = {
			DisplayName = "Coal",
			SellPrice = 10,
			ShowInLeaderstats = true,
			FactoryEnabled = false,
			Worker = {
				DisplayName = "Coal NPC",
				BaseCost = 500,
				TemplateName = "CoalProcessor",
				ActionAnimationId = "rbxassetid://522635514",
				Behavior = "CoalProcessor",
				Unlock = "RequiresFactoryItem:ConveyorCollectionBin",
			},
			ManualCollection = {
				Enabled = false,
				ActionText = "Mine",
				ObjectText = "Coal",
				Amount = 1,
				Unlock = nil,
			},
			DropAppearance = {
				Size = Vector3.new(1.1, 1.1, 1.1),
				Color = Color3.fromRGB(20, 20, 20),
				Material = Enum.Material.Basalt,
			},
		},
	} :: { [Types.ResourceId]: Types.ResourceDefinition },
}

function Config.Get(resourceId: any): Types.ResourceDefinition?
	return if typeof(resourceId) == "string" then Config.Definitions[resourceId] else nil
end

function Config.IsValid(resourceId: any): boolean
	return Config.Get(resourceId) ~= nil
end

function Config.GetDefaultFactoryResource(): Types.ResourceId?
	for _, resourceId in Config.Order do
		local definition = Config.Get(resourceId)
		if definition and definition.FactoryEnabled then
			return resourceId
		end
	end
	return nil
end

return Config
