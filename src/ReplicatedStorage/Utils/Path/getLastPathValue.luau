local function GetLastPathValue(path: string): string?
	local lastValue: string? = nil

	for part in string.gmatch(path, "[^%.]+") do
		lastValue = part
	end

	return lastValue
end

return GetLastPathValue
