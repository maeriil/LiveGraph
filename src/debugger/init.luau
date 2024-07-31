--//TODO: Debugger UI will be created here

--[[
  We want to show the control widgets, window bar, and the window ribbons only when
  the debugger UI is to be used. Otherwise we just return the single frame containing
  the graph.

  The idea is similar to hoarcekat story where we mount the created frame to our 
  debugger like this

  ```lua
    local linegraph = require(path.to.graph).LineGraph
    local debugger = require(path.to.graph.debugger).Debugger

    local graph, graph_handler = linegraph()
    local debugger_handler = debugger(graph, graph_handler)

    debugger_handler.cleanup()
  ```
]]
local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local DEBUGGER_SCREEN_NAME = `LINEGRAPH_DEBUGGER`

local default_debugger_config = {
	showControlWidgets = true,
	showNavigationRibbons = true,
	showWindowBar = true,
}

export type DebuggerConfig = typeof(default_debugger_config)

local function debugger(frame: Frame, config: DebuggerConfig?)
	assert(runservice:IsStudio(), `Debugger for now can only be used in studio env`)

	local player = players.LocalPlayer
	local player_gui = player:WaitForChild("PlayerGui")
	local screen_gui = player_gui:FindFirstChild(DEBUGGER_SCREEN_NAME)

	if not screen_gui then
		screen_gui = Instance.new("ScreenGui")
		screen_gui.Name = DEBUGGER_SCREEN_NAME
	end

	--//TODO: we need to attach all the widgets here
	frame.Parent = screen_gui
end

return {
	Debugger = debugger,
}
