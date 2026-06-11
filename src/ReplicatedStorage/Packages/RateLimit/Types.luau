--!strict

export type RateLimitState = {
	allowance: number,
	last_check: number,
}

export type RateLimit = {
	sources: { [any]: RateLimitState },
	rate: number,
	rate_period: number,
	is_full_wait: boolean,
	CheckRate: (self: RateLimit, source: any) -> boolean,
	CleanSource: (self: RateLimit, source: any) -> (),
	Cleanup: (self: RateLimit) -> (),
	Destroy: (self: RateLimit) -> (),
}

export type RateLimitModule = {
	__index: RateLimit,
	New: (rate: number, is_full_wait: boolean?) -> RateLimit,
}

return {}
