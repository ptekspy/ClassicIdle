--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService_Default = require(ReplicatedStorage.Services.DataService.Default)
local DataService_Types = require(ReplicatedStorage.Services.DataService.Types)
local React = require(ReplicatedStorage.Vendor.React)
local Replica = require(ReplicatedStorage.Packages.Replica.Client)
local ReplicaTypes = require(ReplicatedStorage.Packages.Replica.Client.Types)

type PlayerData = DataService_Types.PlayerData
type PlayerDataReplica = ReplicaTypes.Replica & {
	Data: PlayerData,
}

type PlayerDataProviderProps = {
	children: React.ReactNode,
}

local PlayerDataContext = React.createContext(nil :: PlayerData?)

local function copySnapshot(data: PlayerData): PlayerData
	return table.clone(data) :: PlayerData
end

local function PlayerDataProvider(props: PlayerDataProviderProps)
	local playerData, setPlayerData = React.useState(copySnapshot(DataService_Default :: PlayerData))

	React.useEffect(function()
		local changeConnection: ReplicaTypes.SignalConnection? = nil

		local newReplicaConnection = Replica.OnNew("PlayerData", function(replica: PlayerDataReplica)
			setPlayerData(copySnapshot(replica.Data))

			changeConnection = replica:OnChange(function()
				setPlayerData(copySnapshot(replica.Data))
			end)
		end)

		Replica.RequestData()

		return function()
			newReplicaConnection:Disconnect()

			if changeConnection then
				changeConnection:Disconnect()
			end
		end
	end, {})

	return React.createElement(PlayerDataContext.Provider, {
		value = playerData,
	}, props.children)
end

local function usePlayerData(): PlayerData
	local playerData = React.useContext(PlayerDataContext)

	if playerData == nil then
		error("usePlayerData must be used inside PlayerDataProvider")
	end

	return playerData
end

return {
	Provider = PlayerDataProvider,
	usePlayerData = usePlayerData,
}
