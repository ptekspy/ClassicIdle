--!strict
-- Shared type definitions for the Signal module

export type Connection = {
	Disconnect: (self: Connection) -> (),
	IsConnected: boolean,
}

export type Signal<T...> = {
	Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, T...) -> (),
	FireUntil: (self: Signal<T...>, continue_callback: () -> boolean, T...) -> (),
}

return {}
