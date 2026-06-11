local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MaidTypes = require(ReplicatedStorage.Packages.Maid.Types)

export type Path = { string | number }

export type Replica = {
	Tags: { [any]: any },
	Data: { [any]: any },
	Id: number,
	Token: string,
	Parent: Replica?,
	Children: { [Replica]: boolean? },
	BoundInstance: Instance?,
	OnServerEvent: { Connect: (self: any, listener: (Player, ...any) -> ()) -> { Disconnect: (self: any) -> () } },
	Maid: MaidTypes.Maid,

	Set: (self: any, path: Path, value: any) -> (),
	SetValues: (self: any, path: Path, values: { [string]: any }) -> (),
	TableInsert: (self: any, path: Path, value: any, index: number?) -> number,
	TableRemove: (self: any, path: Path, index: number) -> any,
	Write: (self: any, function_name: string, ...any) -> ...any,
	FireClient: (self: any, player: Player, ...any) -> (),
	FireAllClients: (self: any, ...any) -> (),
	UFireClient: (self: any, player: Player, ...any) -> (),
	UFireAllClients: (self: any, ...any) -> (),
	SetParent: (self: any, new_parent: Replica) -> (),
	BindToInstance: (self: any, instance: Instance) -> (),
	Replicate: (self: any) -> (),
	DontReplicate: (self: any) -> (),
	Subscribe: (self: any, player: Player) -> (),
	Unsubscribe: (self: any, player: Player) -> (),
	Identify: (self: any) -> string,
	IsActive: (self: any) -> boolean,
	Destroy: (self: any) -> (),
}

return {}
