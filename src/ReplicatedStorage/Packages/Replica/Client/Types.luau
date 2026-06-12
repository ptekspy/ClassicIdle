local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MaidTypes = require(ReplicatedStorage.Packages.Maid.Types)

export type SignalConnection = {
	Disconnect: (self: any) -> (),
}

export type Path = { string | number }

export type Replica = {
	Tags: { [any]: any },
	Data: { [any]: any },
	Id: number,
	Token: string,
	Parent: Replica?,
	Children: { [Replica]: boolean? },
	BoundInstance: Instance?,
	OnClientEvent: { Connect: (self: any, listener: (...any) -> ()) -> SignalConnection },
	Maid: MaidTypes.Maid,

	OnSet: (self: any, path: Path, listener: (new_value: any, old_value: any) -> ()) -> SignalConnection,
	OnWrite: (self: any, function_name: string, listener: (...any) -> ()) -> SignalConnection,
	OnChange: (
		self: any,
		listener: (
			action: "Set" | "SetValues" | "TableInsert" | "TableRemove",
			path: Path,
			param1: any,
			param2: any?
		) -> ()
	) -> SignalConnection,
	GetChild: (self: any, token: string) -> Replica?,
	FireServer: (self: any, ...any) -> (),
	UFireServer: (self: any, ...any) -> (),
	Identify: (self: any) -> string,
	IsActive: (self: any) -> boolean,
}

return {}