--!strict

local Table = {}

export type Dictionary = { [any]: any }

function Table.ShallowMerge(...: Dictionary): Dictionary
	local result = {}

	for _, source in ipairs({ ... }) do
		if type(source) == "table" then
			for key, value in pairs(source) do
				result[key] = value
			end
		end
	end

	return result
end

function Table.DeepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end

	local result = {}
	for key, child in pairs(value) do
		result[Table.DeepCopy(key)] = Table.DeepCopy(child)
	end

	return result
end

function Table.DeepMerge(...: Dictionary): Dictionary
	local result = {}

	for _, source in ipairs({ ... }) do
		if type(source) == "table" then
			for key, value in pairs(source) do
				if type(value) == "table" and type(result[key]) == "table" then
					result[key] = Table.DeepMerge(result[key], value)
				else
					result[key] = Table.DeepCopy(value)
				end
			end
		end
	end

	return result
end

return Table
