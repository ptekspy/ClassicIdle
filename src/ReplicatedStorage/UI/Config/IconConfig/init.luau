--!strict

local function icon(asset: string, ratio: number?)
	return table.freeze({ Asset = asset, AspectRatio = ratio or 1 })
end

local Icons = {
	Gold = icon("rbxassetid://75172268678896"),
	Gems = icon("rbxassetid://72681726050121"),
	Fuel = icon("rbxassetid://126380143071254"),
	Trophy = icon("rbxassetid://133985362647737"),
	Level = icon("rbxassetid://103952227838208"),
	Wheel = icon("rbxassetid://123853589643830"),
	Calendar = icon("rbxassetid://105502987968591"),
	Earth = icon("rbxassetid://74788537494081"),
	Moon = icon("rbxassetid://140254719572840"),

	Gift = icon("rbxassetid://111921330601791"),
	Meteor = icon("rbxassetid://110587380688018"),
	Shop = icon("rbxassetid://120377434809387"),

	Rocket = icon("rbxassetid://129253752956835"),
	Pets = icon("rbxassetid://101726372604270"),

	Rebirth = icon("rbxassetid://135334700216157"),
	Codes = icon("rbxassetid://72833422206078"),
	Settings = icon("rbxassetid://110729428635050"),
	Friends = icon("rbxassetid://91345286988875"),
	Backpack = icon("rbxassetid://71781218170388"), --
	Lock = icon("rbxassetid://96184445078942"),
	Collapse = icon("rbxassetid://135172732901720"),
}

Icons.Quest = Icons.Rocket
Icons.Build = Icons.Rocket
Icons.Worlds = Icons.Earth

return table.freeze(Icons)
