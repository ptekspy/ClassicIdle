--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local changed = Signal.New()
local state = {
	feedback = nil,
	quest = nil,
	questMarker = nil,
	interaction = nil,
	workerMenu = nil,
	machineMenu = nil,
	factory = nil,
}

local UIState = {}

function UIState.Get(): any
	return state
end

function UIState.Set(key: string, value: any)
	state = table.clone(state)
	state[key] = value
	changed:Fire(state)
end

function UIState.Subscribe(callback: (any) -> ()): any
	return changed:Connect(callback)
end

return UIState
