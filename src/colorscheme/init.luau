local themetype = require(script.type)

local kanagawa = require(script.kanagawa)

export type Colorscheme = themetype.Colorscheme

return {
	default = kanagawa,
	kanagawa = kanagawa,
}
