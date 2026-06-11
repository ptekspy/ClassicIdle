export type Blacklist = {
	[string]: boolean,
}

local function CopyData(data: {}, blacklist: Blacklist?)
	local copied = {}

	for key, value in data do
		if blacklist == nil or blacklist[key] ~= true then
			copied[key] = value
		end
	end

	return copied
end

return CopyData
