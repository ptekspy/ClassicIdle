--!strict

local Types = require(script.Parent.Types)

export type PartDefinition = {
	DisplayName: string,
	PurchaseCost: number,
	Upgradeable: boolean,
}

local Config = {
	PartOrder = {
		"Conveyor1",
		"Upgrader1",
		"CoalProcessor",
		"Conveyor2",
		"Upgrader2",
		"CollectionPoint",
	} :: { Types.MachinePartId },
	Parts = {
		Conveyor1 = { DisplayName = "Conveyor 1", PurchaseCost = 100, Upgradeable = true },
		Upgrader1 = { DisplayName = "Upgrader 1", PurchaseCost = 150, Upgradeable = true },
		CoalProcessor = { DisplayName = "Coal Processor", PurchaseCost = 250, Upgradeable = true },
		Conveyor2 = { DisplayName = "Conveyor 2", PurchaseCost = 200, Upgradeable = true },
		Upgrader2 = { DisplayName = "Upgrader 2", PurchaseCost = 300, Upgradeable = true },
		CollectionPoint = { DisplayName = "Collection Point", PurchaseCost = 400, Upgradeable = true },
	} :: { [Types.MachinePartId]: PartDefinition },
	RecipeWood = 2,
	RecipeStone = 1,
	DispatchInterval = 1,
	CollectionCapacity = 50,
	CollectionCapacityPerLevel = 25,
	ConveyorBaseSpeed = 6,
	ConveyorSpeedPerLevel = 1.5,
	UpgraderBaseMultiplier = 2,
	UpgraderMultiplierPerLevel = 0.5,
	ProcessorBaseDuration = 4,
	ProcessorDurationReductionPerLevel = 0.5,
	ProcessorMinimumDuration = 1,
	ProcessorBaseOutputMultiplier = 1.5,
	ProcessorOutputMultiplierPerLevel = 0.25,
}

function Config.GetConveyorSpeed(level: number): number
	return Config.ConveyorBaseSpeed + (math.max(1, level) - 1) * Config.ConveyorSpeedPerLevel
end

function Config.GetUpgraderMultiplier(level: number): number
	return Config.UpgraderBaseMultiplier + (math.max(1, level) - 1) * Config.UpgraderMultiplierPerLevel
end

function Config.GetProcessorDuration(level: number): number
	return math.max(
		Config.ProcessorMinimumDuration,
		Config.ProcessorBaseDuration - (math.max(1, level) - 1) * Config.ProcessorDurationReductionPerLevel
	)
end

function Config.GetProcessorOutputMultiplier(level: number): number
	return Config.ProcessorBaseOutputMultiplier + (math.max(1, level) - 1) * Config.ProcessorOutputMultiplierPerLevel
end

function Config.GetUpgradeCost(partId: Types.MachinePartId, level: number): number
	return Config.Parts[partId].PurchaseCost * math.max(1, level)
end

function Config.GetCollectionCapacity(level: number): number
	return Config.CollectionCapacity + (math.max(1, level) - 1) * Config.CollectionCapacityPerLevel
end

return Config
