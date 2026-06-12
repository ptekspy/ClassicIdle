--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReactRoblox = require(ReplicatedStorage.Vendor.ReactRoblox)

local roots: { [Instance]: any } = {}
local WorldUIService = {}

function WorldUIService.Render(host: Instance, element: any)
	local root = roots[host]
	if not root then
		root = ReactRoblox.createRoot(host)
		roots[host] = root
	end
	root:render(element)
end

function WorldUIService.Unmount(host: Instance)
	local root = roots[host]
	roots[host] = nil
	if root then
		root:unmount()
	end
end

function WorldUIService.UnmountTree(ancestor: Instance)
	local hosts = {}
	for host in roots do
		if host == ancestor or host:IsDescendantOf(ancestor) then
			table.insert(hosts, host)
		end
	end
	for _, host in hosts do
		WorldUIService.Unmount(host)
	end
end

return WorldUIService