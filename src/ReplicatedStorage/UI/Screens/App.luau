--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local PlayerDataContext = require(script.Parent.Parent.Context.PlayerDataContext)
local FeedbackScreen = require(script.Parent.FeedbackScreen)
local QuestScreen = require(script.Parent.QuestScreen)
local InteractionScreen = require(script.Parent.InteractionScreen)
local MachineScreen = require(script.Parent.MachineScreen)
local WorkerScreen = require(script.Parent.WorkerScreen)
local FactoryScreen = require(script.Parent.FactoryScreen)

local function App(props: { state: any })
	return React.createElement(PlayerDataContext.Provider, nil, {
		Feedback = React.createElement(FeedbackScreen, {
			feedback = props.state.feedback,
		}),
		Quest = React.createElement(QuestScreen, {
			quest = props.state.quest,
			questMarker = props.state.questMarker,
		}),
		Interaction = React.createElement(InteractionScreen, {
			interaction = props.state.interaction,
		}),
		Worker = React.createElement(WorkerScreen, {
			menu = props.state.workerMenu,
		}),
		Machine = React.createElement(MachineScreen, {
			menu = props.state.machineMenu,
		}),
		Factory = React.createElement(FactoryScreen, {
			factory = props.state.factory,
		}),
	})
end

return App
