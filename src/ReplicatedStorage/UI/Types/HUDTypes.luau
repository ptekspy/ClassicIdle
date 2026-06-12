--!strict

export type QuestView = {
	title: string,
	description: string,
	progress: number,
	required: number,
	xpReward: number,
}

export type HotbarItem = {
	id: string,
	name: string,
	count: number,
	icon: string,
	locked: boolean,
}

export type FactoryActions = {
	onToggleShop: () -> (),
	onSelectItem: (string) -> (),
}

export type ResponsiveMode = "Desktop" | "Tablet" | "LandscapePhone" | "PortraitPhone"

return {}