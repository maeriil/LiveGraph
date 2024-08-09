--[[
	Main export file

	GUIDELINES

	Since most users in roblox ecosystem use PascalCase for Instances and camelCase
	for the functions associated with it, we will be adopting a similar style. 

	For example:
		the debugger module's root function will be exported as Debugger.
		the function's associated with debugger in that module should be exported
		in camelCase. Therefore, it would look like

		```lua
			local Debugger = require(graph).Debugger
			local mydebugger = Debugger()

			mydebugger.sampleFunction()
		```

		Internally, we follow a very simple but strict guidelines. The module imports
		are always on lowercase and everything else is always snake_case. Below is an
		example

		```lua
			local samplerequire = require(path.to.samplerequire)
			local something_var = samplerequire.some_function()

			return {
				exports_will_be_snake_case = something_var
			}
		```

	Ensure that the types associated with the modules are exported as well
]]

local debugger = require(script.debugger)
export type DebuggerConfig = debugger.DebuggerConfig

local bulletgraph = require(script.graph.bulletgraph)
export type BulletGraphProps = bulletgraph.BulletGraphProps
export type BulletGraph = bulletgraph.BulletGraph

return {
	Debugger = debugger,
	BulletGraph = bulletgraph,
}
