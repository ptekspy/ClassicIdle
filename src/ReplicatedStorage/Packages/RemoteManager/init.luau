local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RemotesFolder = script
local EventsFolder = ReplicatedStorage.Packages.RemoteManager.Events
local FunctionsFolder = ReplicatedStorage.Packages.RemoteManager.Functions
local EventsList = require(EventsFolder.Events)
local FunctionsList = require(FunctionsFolder.Functions)

local function getOrCreate(name: string, type: "RemoteEvent" | "RemoteFunction", parent)
    local existing = parent:FindFirstChild(name)
    if existing == nil then
        if not RunService:IsServer() then
            return parent:WaitForChild(name)
        end

        existing = Instance.new(type, parent)
        existing.Name = name
    end

    return existing
end

local function getOrCreateRemoteEvent(name: string)
    return getOrCreate(name, "RemoteEvent", EventsFolder)
end

local function getOrCreateRemoteFunction(name: string)
    return getOrCreate(name, "RemoteFunction", FunctionsFolder)
end

local Shared = {
    -- ******************
    -- Folders
    -- ******************
    Root = RemotesFolder,
    EventsFolder = EventsFolder,
    FunctionsFolder = FunctionsFolder,
}


for _, remoteEventName in ipairs(EventsList) do
    Shared[remoteEventName] = getOrCreateRemoteEvent(remoteEventName)
end

for _, remoteFunctionName in ipairs(FunctionsList) do
    Shared[remoteFunctionName] = getOrCreateRemoteFunction(remoteFunctionName)
end

return Shared
