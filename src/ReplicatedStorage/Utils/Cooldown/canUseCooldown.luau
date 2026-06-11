local function canUseCooldown(
	player: Player,
	cooldowns: {[Player]: number},
	cooldownSeconds: number
): boolean
	local now = os.clock()
	local lastUsed = cooldowns[player] or 0

	if now - lastUsed < cooldownSeconds then
		return false
	end

	cooldowns[player] = now
	return true
end

return canUseCooldown