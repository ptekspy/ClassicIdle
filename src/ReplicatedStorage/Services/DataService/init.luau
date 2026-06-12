--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
local Types = require(script.Types)
local DEFAULT_DATA = require(script.Default)

local Local = {
	STORE_NAME = "IdleGame_PlayerData_v8",
	profiles = {} :: { [Player]: Types.PlayerProfile },
	states = {} :: { [Player]: Types.SessionState },
}

Local.store = ProfileStore.New(Local.STORE_NAME, DEFAULT_DATA)

local DataService = {}

function DataService.Get(player: Player): Types.PlayerData
	local profile = Local.profiles[player]

	if Local.states[player] ~= "Loaded" or not profile or not profile:IsActive() then
		error(`No data loaded for {player.Name}`)
	end

	return profile.Data
end

function DataService.TryGet(player: Player): Types.PlayerData?
	local profile = Local.profiles[player]

	if Local.states[player] ~= "Loaded" or not profile or not profile:IsActive() then
		return nil
	end

	return profile.Data
end

function DataService.IsLoaded(player: Player): boolean
	return DataService.TryGet(player) ~= nil
end

function DataService.Load(player: Player): boolean
	if Local.states[player] == "Loading" or Local.states[player] == "Loaded" then
		return false
	end

	Local.states[player] = "Loading"

	-- ProfileStore retries failed requests internally.
	local profile = Local.store:StartSessionAsync(`player_{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile == nil then
		if player.Parent == Players then
			Local.states[player] = "LoadFailed"
			player:Kick("Your data could not be loaded. Please rejoin.")
		else
			Local.states[player] = nil
		end

		return false
	end

	if player.Parent ~= Players then
		profile:EndSession()
		Local.states[player] = nil
		return false
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function()
		Local.profiles[player] = nil

		if player.Parent == Players then
			Local.states[player] = "LoadFailed"
			player:Kick("Your data session ended. Please rejoin.")
		else
			Local.states[player] = nil
		end
	end)

	Local.profiles[player] = profile
	Local.states[player] = "Loaded"

	return true
end

function DataService.Release(player: Player)
	local profile = Local.profiles[player]

	Local.profiles[player] = nil
	Local.states[player] = nil

	if profile and profile:IsActive() then
		profile:EndSession()
	end
end

return DataService
