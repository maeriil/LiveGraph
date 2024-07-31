local themetype = require(script.Parent.type)

--//FIXME: We need to update this according to the themetype
local theme: themetype.Colorscheme = {
	["foreground"] = Color3.fromHex(`#DCD7BA`),
	["coloured-foreground"] = Color3.fromHex(`#938AA9`),
	["dark-foreground"] = Color3.fromHex(`#C8C093`),
	["darker-foreground"] = Color3.fromHex(`#54546D`),
	["background"] = Color3.fromHex(`#1F1F28`),
	["dark-background"] = Color3.fromHex(`#16161D`),
	["light-background"] = Color3.fromHex(`#2A2A37`),
	["lighter-background"] = Color3.fromHex(`#363646`),
	["popup-background"] = Color3.fromHex(`#223249`),
	["popup-selection-background"] = Color3.fromHex(`#2D4F67`),

	["disabled-text"] = Color3.fromHex(`#717C7C`),
	["disabled-darker"] = Color3.fromHex(`#727169`),
	["success-text"] = Color3.fromHex(`#98BB6C`),
	["warning-text"] = Color3.fromHex(`#FFA066`),
	["accent-text-1"] = Color3.fromHex(`#FF5D62`),
	["accent-text-2"] = Color3.fromHex(`#E46876`),
	["span-text"] = Color3.fromHex(`#D27E99`),
	["span-accent"] = Color3.fromHex(`#957FB8`),
	["title"] = Color3.fromHex(`#7E9CD8`),
	["title-soft"] = Color3.fromHex(`#7FB4CA`),
	["text-soft"] = Color3.fromHex(`#E6C384`),
	["text-medium"] = Color3.fromHex(`#C0A36E`),
	["text-hard"] = Color3.fromHex(`#938056`),

	["error"] = Color3.fromHex(`#E82424`),
	["warning"] = Color3.fromHex(`#FF9E3B`),
	["info"] = Color3.fromHex(`#6A9589`),
	["hint"] = Color3.fromHex(`#658594`),

	-- TO_SORT
	["diff-add"] = Color3.fromHex(`#2B3328`),
	["diff-change"] = Color3.fromHex(`#49443C`),
	["diff-deleted"] = Color3.fromHex(`#43242B`),
	["diff-line"] = Color3.fromHex(`#252535`),
} :: themetype.Colorscheme

return theme
