--!strict

local Types = require(script.Parent.Types)

export type RoleDefinition = {
	DisplayName: string,
	BaseCost: number,
	TemplateName: string,
	ActionAnimationId: string,
	ResourceType: Types.ResourceType?,
}

local Config = {
	IdleAnimationId = "rbxassetid://507766666",
	DefaultCapacity = 25,
	DefaultRespawnSeconds = 5,
	MoveTimeoutSeconds = 15,
	RetrySeconds = 1,
	ActionSeconds = 1,
	DepositRetrySeconds = 1,
	CoalRecipeWood = 2,
	CoalRecipeStone = 1,
	Roles = {
		Wood = {
			DisplayName = "Wood NPC",
			BaseCost = 10,
			TemplateName = "Wood",
			ActionAnimationId = "rbxassetid://522635514",
			ResourceType = "Wood",
		},
		Stone = {
			DisplayName = "Stone NPC",
			BaseCost = 25,
			TemplateName = "Stone",
			ActionAnimationId = "rbxassetid://522635514",
			ResourceType = "Stone",
		},
		CoalProcessor = {
			DisplayName = "Coal Processor NPC",
			BaseCost = 100,
			TemplateName = "CoalProcessor",
			ActionAnimationId = "rbxassetid://522635514",
			ResourceType = nil,
		},
	} :: { [Types.Role]: RoleDefinition },
}

return Config
