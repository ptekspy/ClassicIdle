local RunService = game:GetService("RunService")
local Types = require(script.Types)

local IS_STUDIO = RunService:IsStudio()

local Logger = {}
Logger.__index = Logger

local LogLevel = {
	Debug = 1,
	Info = 2,
	Warn = 3,
	Error = 4,
	Off = 5,
}

local function isValidLevel(level)
	return type(level) == "string" and LogLevel[level] ~= nil
end

local function formatTable(value, depth, visited)
	depth = depth or 1
	if depth > 3 then
		return "{...}"
	end

	visited = visited or {}
	if visited[value] then
		return "{<cycle>}"
	end

	visited[value] = true

	local parts = {}
	local isArray = true
	for key in pairs(value) do
		if type(key) ~= "number" or key < 1 or key ~= math.floor(key) then
			isArray = false
			break
		end
	end

	if isArray then
		for i = 1, #value do
			table.insert(parts, formatTable(value[i], depth + 1, visited))
		end
		visited[value] = nil
		return "{" .. table.concat(parts, ", ") .. "}"
	end

	for key, item in pairs(value) do
		local formattedKey = tostring(key)
		local formattedValue = if type(item) == "table" then formatTable(item, depth + 1, visited) else tostring(item)
		table.insert(parts, `[{formattedKey}] = {formattedValue}`)
	end

	visited[value] = nil
	return "{" .. table.concat(parts, ", ") .. "}"
end

local function safeToString(value)
	if type(value) == "table" then
		return formatTable(value)
	end
	return tostring(value)
end

local function formatArgs(...)
	local args = table.pack(...)
	local parts = {}

	for i = 1, args.n do
		table.insert(parts, safeToString(args[i]))
	end

	return table.concat(parts, " ")
end

local function formatTimestamp()
	return os.date("%Y-%m-%d %H:%M:%S")
end

local function createMessage(self, level, ...)
	local message = formatArgs(...)
	local timestamp = if self._timestamps then `[{formatTimestamp()}] ` else ""
	return `[{level}] {timestamp}[{self._prefix}]: {message}`
end

local function defaultOutput(level, message)
	if level == "Warn" then
		warn(message)
	elseif level == "Error" then
		error(message, 2)
	else
		print(message)
	end
end

function Logger.new(prefix: string, config: Types.LoggerConfig?): Types.ILogger
	local enabled = if config and config.enabled ~= nil then config.enabled else IS_STUDIO
	local level = if config and isValidLevel(config.level) then config.level else "Debug"
	local timestamps = if config and config.timestamps then true else false

	return setmetatable({
		_prefix = prefix,
		_enabled = enabled,
		_level = level,
		_timestamps = timestamps,
		_output = config and config.output,
	}, Logger) :: any
end

function Logger:ShouldLog(level)
	if not self._enabled then
		return false
	end

	if not isValidLevel(level) or level == "Off" then
		return false
	end

	return LogLevel[level] >= LogLevel[self._level]
end

function Logger:Write(level, ...)
	if not self:ShouldLog(level) then
		return
	end

	local message = createMessage(self, level, ...)

	if self._output then
		self._output(self, level, self._prefix, message)
	else
		defaultOutput(level, message)
	end
end

function Logger:Debug(...: any)
	self:Write("Debug", ...)
end

function Logger:Info(...: any)
	self:Write("Info", ...)
end

function Logger:Log(...: any)
	self:Info(...)
end

function Logger:Warn(...: any)
	self:Write("Warn", ...)
end

function Logger:Error(...: any)
	local message = createMessage(self, "Error", ...)

	if not self:ShouldLog("Error") then
		return
	end

	if self._output then
		self._output(self, "Error", self._prefix, message)
	end

	error(message, 2)
end

function Logger:SetPrefix(prefix: string)
	self._prefix = prefix
end

function Logger:SetLevel(level: string)
	if isValidLevel(level) then
		self._level = level
	end
end

function Logger:SetEnabled(enabled: boolean)
	self._enabled = enabled
end

function Logger:SetTimestamps(enabled: boolean)
	self._timestamps = enabled
end

function Logger:SetOutput(output: ((self: Types.ILogger, level: string, prefix: string, message: string) -> ())?)
	self._output = output
end

return Logger
