--!strict

local Types = require(script.Parent.Types)
local ResourceConfig = require(script.Parent.Parent.Resource.Config)

export type RoleDefinition = {
	DisplayName: string,
	BaseCost: number,
	TemplateName: string,
	ActionAnimationId: string,
	ResourceType: Types.ResourceType?,
	Behavior: string,
}

local roles = {} :: { [string]: RoleDefinition }
for _, resourceId in ResourceConfig.Order do
	local definition = ResourceConfig.Get(resourceId)
	local worker = definition and definition.Worker
	if worker then
		roles[resourceId] = {
			DisplayName = worker.DisplayName,
			BaseCost = worker.BaseCost,
			TemplateName = worker.TemplateName,
			ActionAnimationId = worker.ActionAnimationId,
			ResourceType = resourceId,
			Behavior = worker.Behavior,
		}
	end
end

local Config = {
	IdleAnimationId = "rbxassetid://507766666",
	DefaultCapacity = 25,
	DefaultRespawnSeconds = 5,
	MoveTimeoutSeconds = 15,
	RetrySeconds = 1,
	ActionSeconds = 1,
	DepositRetrySeconds = 1,
	Roles = roles,
}

return Config
