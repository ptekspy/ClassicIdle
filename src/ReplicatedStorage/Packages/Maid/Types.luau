export type MaidToken = {
	maid: Maid,
	object: any,
	Destroy: (self: MaidToken) -> (),
	Cleanup: (self: MaidToken, ...any) -> (),
}

export type Maid = {
	tokens: { [MaidToken]: boolean },
	is_cleaned: boolean,
	key: any,
	IsActive: (self: Maid) -> boolean,
	Add: (self: Maid, object: any) -> MaidToken,
	Cleanup: (self: Maid, ...any) -> (),
	Unlock: (self: Maid, key: any) -> (),
}

return {}
