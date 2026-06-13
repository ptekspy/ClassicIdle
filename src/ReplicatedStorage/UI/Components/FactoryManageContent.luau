--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local ActionButton = require(script.Parent.ActionButton)
local Panel = require(script.Parent.Panel)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

local function label(text: string, order: number)
	return React.createElement(Text, {
		text = text,
		variant = "Caption",
		color = "Secondary",
		size = UDim2.new(1, -16, 0, 58),
		layoutOrder = order,
		wrapped = true,
	})
end

local function FactoryManageContent(props: { factory: any })
	local factory = props.factory
	local payload = factory.managePayload
	if not payload then
		return nil
	end

	local children = {
		Layout = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Title = React.createElement(Text, {
			text = payload.DisplayName,
			variant = "Label",
			color = "Primary",
			size = UDim2.new(1, 0, 0, 48),
			layoutOrder = 1,
		}),
		Move = React.createElement(ActionButton, {
			text = "MOVE",
			height = 48,
			textSize = 15,
			layoutOrder = 2,
			onActivated = function()
				factory.onMove(payload)
			end,
		}),
	}

	local order = 3
	if payload.ItemId == "ConveyorDropper" then
		children.Description = label(
			"Runs automatically while the selected resource is in Storage and a valid conveyor is connected.",
			order
		)
		order += 1
		for _, resourceId in payload.ResourceOptions or {} do
			local definition = ResourceConfig.Get(resourceId)
			if definition then
				children[`Resource{resourceId}`] = React.createElement(ActionButton, {
					text = `DROP {string.upper(definition.DisplayName)}`,
					height = 48,
					textSize = 15,
					layoutOrder = order,
					onActivated = function()
						factory.onConfigure(payload.PlacedItemId, resourceId)
					end,
				})
				order += 1
			end
		end
	elseif payload.ItemId == "CornerConveyor" then
		children.Reverse = React.createElement(ActionButton, {
			text = "REVERSE CORNER FLOW",
			height = 48,
			textSize = 15,
			layoutOrder = order,
			onActivated = function()
				factory.onConfigure(payload.PlacedItemId, if payload.ConnectorMode == 2 then 1 else 2)
			end,
		})
	elseif payload.ItemId == "ConveyorCollectionBin" then
		children.Description =
			label("Factory output waits here. Collect it manually to move as much as possible into Storage.", order)
		children.Collect = React.createElement(ActionButton, {
			text = `COLLECT {payload.StoredAmount or 0} {payload.StoredResourceType or ""}`,
			height = 48,
			textSize = 15,
			layoutOrder = order + 1,
			onActivated = function()
				factory.onCollect(payload.PlacedItemId)
			end,
		})
	end

	children.Close = React.createElement(ActionButton, {
		text = "CLOSE",
		height = 48,
		textSize = 15,
		layoutOrder = 100,
		onActivated = factory.onCloseManage,
	})

	return React.createElement("Frame", {
		Position = UDim2.new(0.5, -160, 0.5, -160),
		Size = UDim2.fromOffset(320, 320),
		BackgroundTransparency = 1,
	}, {
		Panel = React.createElement(Panel, {
			variant = "Status",
			size = UDim2.fromScale(1, 1),
			children = children,
		}),
	})
end

return FactoryManageContent
