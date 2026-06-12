--!strict

local Gradients = {
	PanelBlue = ColorSequence.new(Color3.fromRGB(10, 91, 183), Color3.fromRGB(3, 40, 87)),
	PanelPurple = ColorSequence.new(Color3.fromRGB(105, 58, 218), Color3.fromRGB(37, 17, 91)),
	ButtonGreen = ColorSequence.new(Color3.fromRGB(86, 245, 35), Color3.fromRGB(25, 176, 10)),
	ButtonDisabled = ColorSequence.new(Color3.fromRGB(91, 104, 119), Color3.fromRGB(49, 57, 66)),
	Progress = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 222, 17)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(155, 230, 25)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 205, 16)),
	}),
}

return table.freeze(Gradients)
