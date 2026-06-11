export type LogLevel = "Debug" | "Info" | "Warn" | "Error" | "Off"

export type LoggerConfig = {
	enabled: boolean?,
	level: LogLevel?,
	timestamps: boolean?,
	output: ((self: ILogger, level: LogLevel, prefix: string, message: string) -> ())?,
}

export type ILogger = {
	Log: (self: ILogger, ...any) -> (),
	Debug: (self: ILogger, ...any) -> (),
	Info: (self: ILogger, ...any) -> (),
	Warn: (self: ILogger, ...any) -> (),
	Error: (self: ILogger, ...any) -> (),
	SetPrefix: (self: ILogger, prefix: string) -> (),
	SetLevel: (self: ILogger, level: LogLevel) -> (),
	SetEnabled: (self: ILogger, enabled: boolean) -> (),
	SetTimestamps: (self: ILogger, enabled: boolean) -> (),
	SetOutput: (
		self: ILogger,
		output: ((self: ILogger, level: LogLevel, prefix: string, message: string) -> ())?
	) -> (),
}

return {}
