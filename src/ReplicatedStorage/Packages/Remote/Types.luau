export type Connection = {
	fn: (...any) -> (),
	is_disconnected: boolean,
	real_connection: RBXScriptConnection?,
	Disconnect: (self: Connection) -> (),
}

export type RemoteClientWrapper = {
	OnClientEvent: {
		Connect: (self: any, (...any) -> ()) -> Connection,
	},
	OnServerEvent: {
		Connect: (self: any, ...any) -> (),
	},
	RemoteEvent: RemoteEvent?,
	FireServer: (self: RemoteClientWrapper, ...any) -> (),
	FireClient: (self: RemoteClientWrapper, ...any) -> (),
	FireAllClients: (self: RemoteClientWrapper, ...any) -> (),
}

export type RemoteResult = RemoteEvent | RemoteClientWrapper

export type RemoteModule = {
	New: (name: string, is_unreliable: boolean?) -> RemoteResult,
}

return {}
