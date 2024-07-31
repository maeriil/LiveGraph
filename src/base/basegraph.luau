--[[
	Base graph module

	handles most of the common features for live movement graph other than plotting
	the values and rendering them
]]
--//TODO: Update the colours of each components

local workspace = game:GetService("Workspace")
local colorscheme = require(script.Parent.Parent.colorscheme)
local utility = require(script.Parent.Parent.utility)

--[=[
	Base graph structure
]=]
export type BaseGraph = {
	--[=[
		The actual graph containing all the lines and other containers
		This should never be directly mutated which is why `_` prefix exists.
		The only reason we are exporting this is because we would need to parent
		it to our parent frames/screengui
	]=]
	_graph: Frame,

	--[=[
		Move the base graph's lines to the left which makes it seem that the graph is
		moving. If the lines go outside of the frame, we will need to wrap it around
		from the right and determine the new value for the frame
		@param number shiftamount The number to shift the graph by
	]=]
	move_left: (shiftamount: number) -> (),

	--[=[
		Move the base graph's lines to the right which makes it seem that the graph is
		moving. If the lines go outside of the frame, we will need to wrap it around
		from the left and determine the new value for the frame
		@param number shiftamount The number to shift the graph by
	]=]
	move_right: (shiftamount: number) -> (),

	--[=[
		Move the base graph's lines down which makes it seem that the graph is
		moving downwards. If the lines go outside of the frame, we will need to wrap 
		it around from the top oand determine the new value for the frame
		@param number shiftamount The number to shift the graph by
	]=]
	move_down: (shiftamount: number) -> (),

	--[=[
		Move the base graph's lines up which makes it seem that the graph is
		moving upwards. If the lines go outside of the frame, we will need to wrap 
		it around from the bottom and determine the new value for the frame
		@param number shiftamount The number to shift the graph by
	]=]
	move_up: (shiftamount: number) -> (),

	--[=[
		Spread apart the lines so that it makes it seem like user is zooming in to
		the graph. If the number of lines in the frame being rendered at a given time
		becomes less than some threshold value calculated using frame size, then we
		"reset" the number of lines to maximum lines.\

		For example: If the calculate lines for the graph is min: 4, max: 10 and our
		current lines in the graph is 3, then we reset our lines amount to 10 which
		means that 10 lines are now present in the graph. Then we calculate the new
		values for each of these lines, which would be smaller in scale than before
		
		In order to visually see what this looks like, try to zoom in/out in 
		www.desmos.com/calculator

		@param number zoomamount the number to zoom into the graph by
	]=]
	zoom_in: (zoomamount: number) -> (),

	--[=[
		Shrink the lines so that it makes it seem like user is zooming out of the
		graph. If the number of lines in the frame being rendered at a given time
		becomes greater than some threshold value calculated using frame size, then we
		"reset" the number of lines to minimum lines.\

		For example: If the calculate lines for the graph is min: 4, max: 10 and our
		current lines in the graph is 11, then we reset our lines amount to 4 which
		means that 4 lines are now present in the graph. Then we calculate the new
		values for each of these lines, which would be larger in scale than before 
		
		In order to visually see what this looks like, try to zoom in/out in 
		www.desmos.com/calculator

		@param number zoomamount the number to zoom into the graph by
	]=]
	zoom_out: (zoomamount: number) -> (),

	--[=[
		Update the graph so that all the changes made to the lines and etc are displayed
		in the graph frame. This should typically be the last function to be called
		on each frame.
	]=]
	update_render: () -> (),
}

--[=[
	Find the new difference value our graph should have based on how many levels of
	zoom increments we have done

	When we zoom in or zoom out, we want to set our differences such that it
	follows the following pattern:
	[1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, ...] and similarly on
	the reverse order as well, i.e [1/1, 1/2, 1/5, 1/10, 1/20, ...]
	This is the similar pattern which desmos does their scalling as well when we
	zoom in/out of the graph. 

	@param number count The zoom factor
	@return number A new difference value
]=]
local function calculate_pos_diff(count: number): number
	if count == 0 then
		return 1
	elseif count == 1 then
		return 2
	elseif count == 2 then
		return 5
	end

	local num_of_3 = count // 3 - 1
	local remaining = count - num_of_3
	return 5 * 2.5 ^ num_of_3 * 2 ^ (remaining - 3)
end

--[=[
	Calculate the proper scale depending on whether the count is decreasing or
	increasing.\
	If the count is increasing, this means that our scale values will be bigger and
	bigger. They could be negative number as well, but their absolute value will become
	bigger and bigger\
	On the other hand, if it is decreasing, it means it is approaching 0. So it becomes
	smaller and smaller 
	@param number count The zoom factor
	@return number A new difference value depending on what the count is
]=]
local function calculate_new_scale_diff(count: number): number
	return if count < 0 then 1 / calculate_pos_diff(math.abs(count)) else calculate_pos_diff(count)
end

--[=[
	Calculate a new value of the line 

	@param number first_value What the starting value of the line is
	@param number count The zoom factor
	@param number entry The ith line to change the value of
	@param boolean neg The optional boolean which specifies that negative value
	could be used
	@return number the new value of the line to use
]=]
local function calculate_new_value(
	first_value: number,
	count: number,
	entry: number,
	neg: boolean?
): number
	local diff = calculate_new_scale_diff(count)
	return if neg then first_value - (diff * entry) else first_value + (diff * entry)
end

local function calculate_new_line_values(line: { Line }, count: number, neg: boolean?): ()
	if utility.get_table_size(line) < 0 then
		return
	end

	local first_pos = line[1].value
	local diff = calculate_new_scale_diff(count)

	for i, v in line do
		local increment = (i - 1) * diff
		v.value = if neg then first_pos - increment else first_pos + increment
	end
end

export type BaseGraphProps = {
	[string]: { __SEALED_TABLE__: true },

	colorscheme: colorscheme.Colorscheme,

	hide_label: boolean?,

	size: Vector2?,
	position: Vector2?,
	anchorpoint: Vector2?,
}

--[=[
	Line type which is used to represent the lines in the graph.
	@param number position The position represent x or y offset value of the line
	depending on whether it is being rendered horizontally or vertically
	@param number value The value is what this line is representing
	@param render The render is the actual visual render of this line using Frame
	@param label The label is the actual visual render of the text using TextLabel
]=]
export type Line = {
	position: number,
	value: number,
	render: Frame,
	label: TextLabel,
}

local function basegraph(props: BaseGraphProps): BaseGraph
	local BASE_CONTAINER_FRAME_SIZE = Vector2.new(450, 250)
	local MINIMUM_CONTAINER_FRAME_SIZE = Vector2.new(55, 30)
	local DEFAULT_CONTAINER_POSITION = Vector2.new(300, 300)
	local DEFAULT_CONTAINER_ANCHOR_POINT = Vector2.new(0.5, 0.5)
	local DEFAULT_TEXTLABEL_SIZE = Vector2.new(55, 30)

	-- These are the hard limit for all graphs regardless of viewport changes
	local MAXIMUM_LINES_IN_FRAME = 15 --//TODO: change this to something like 10-15
	local MINIMUM_LINES_IN_FRAME = 5

	local function cap_size(desired: Vector2): Vector2
		return Vector2.new(
			math.max(desired.X, MINIMUM_CONTAINER_FRAME_SIZE.X),
			math.max(desired.Y, MINIMUM_CONTAINER_FRAME_SIZE.Y)
		)
	end

	local viewport = workspace.CurrentCamera.ViewportSize
	local container_sz = if props.size then cap_size(props.size) else BASE_CONTAINER_FRAME_SIZE
	local container_pos = props.position or DEFAULT_CONTAINER_POSITION
	local container_anchor = props.anchorpoint or DEFAULT_CONTAINER_ANCHOR_POINT
	local label_size = if props.hide_label then Vector2.zero else DEFAULT_TEXTLABEL_SIZE
	local base_sz = container_sz + label_size

	-- How much inwards vertical lines should be from horizontal and vice versa
	local label_offset = 10

	local basegraph_frame = Instance.new("Frame")
	basegraph_frame.Name = "BaseGraph"
	basegraph_frame.Size = UDim2.new(0, 0, 0, 0)
	basegraph_frame.Size = utility.to_udim2(base_sz)
	basegraph_frame.AnchorPoint = container_anchor
	basegraph_frame.Position = utility.to_udim2(container_pos)

	-- local padding = Instance.new("UIPadding")
	-- padding.PaddingRight = UDim.new(0, label_size.X / 2)
	-- padding.Parent = basegraph_frame

	local h_label_sz = Vector2.new(container_sz.X - label_offset, label_size.Y)
	local h_label_pos = Vector2.new(label_size.X / 2 + label_offset, container_sz.Y - label_size.Y)
	local h_label_frame = Instance.new("Frame")
	h_label_frame.Name = "LABEL_H"
	h_label_frame.Size = utility.to_udim2(h_label_sz)
	h_label_frame.Position = utility.to_udim2(h_label_pos)
	h_label_frame.AnchorPoint = Vector2.new(0, 0)
	h_label_frame.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
	h_label_frame.BackgroundTransparency = 1
	h_label_frame.ClipsDescendants = true
	h_label_frame.Parent = basegraph_frame

	local h_line_sz =
		Vector2.new(container_sz.X - label_size.X - label_offset, container_sz.Y - label_size.Y)
	local h_line_pos = Vector2.new(label_size.X + label_offset, 0)
	local h_line_frame = Instance.new("Frame")
	h_line_frame.Name = "LINE_H"
	--//FIXME: As a bandaid for now, we are adding <1, 0> so we can see the line
	-- There has to be better way than to do this...
	h_line_frame.Size = utility.to_udim2(h_line_sz + Vector2.new(1, 0))
	h_line_frame.Position = utility.to_udim2(h_line_pos)
	h_line_frame.AnchorPoint = Vector2.new(0, 0)
	h_line_frame.BackgroundColor3 = Color3.fromRGB(200, 100, 200)
	h_line_frame.BackgroundTransparency = 1
	h_line_frame.ClipsDescendants = true
	h_line_frame.Parent = basegraph_frame

	local v_label_sz = Vector2.new(label_size.X, container_sz.Y - label_offset)
	local v_label_pos = Vector2.new(0, -label_size.Y / 2)
	local v_label_frame = Instance.new("Frame")
	v_label_frame.Name = "LABEL_V"
	v_label_frame.Size = utility.to_udim2(v_label_sz)
	v_label_frame.Position = utility.to_udim2(v_label_pos)
	v_label_frame.AnchorPoint = Vector2.new(0, 0)
	v_label_frame.BackgroundColor3 = Color3.fromRGB(100, 0, 50)
	v_label_frame.BackgroundTransparency = 1
	v_label_frame.ClipsDescendants = true
	v_label_frame.Parent = basegraph_frame

	local v_line_sz =
		Vector2.new(container_sz.X - label_size.X, container_sz.Y - label_size.Y - label_offset)
	local v_line_pos = Vector2.new(label_size.X, 0)
	local v_line_frame = Instance.new("Frame")
	v_line_frame.Name = "LINE_V"
	--//FIXME: As a bandaid for now, we are adding <0, 1> so we can see the line
	-- There has to be better way than to do this...
	v_line_frame.Size = utility.to_udim2(v_line_sz + Vector2.new(0, 1))
	v_line_frame.Position = utility.to_udim2(v_line_pos)
	v_line_frame.AnchorPoint = Vector2.new(0, 0)
	v_line_frame.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
	v_line_frame.BackgroundTransparency = 1
	v_line_frame.ClipsDescendants = true
	v_line_frame.Parent = basegraph_frame

	local h_lines: { Line } = {}
	local v_lines: { Line } = {}

	-- We make sure to always render the maximum amount of lines. However, since
	-- we have clipsdescendant enabled, even if the line is outside of the frame,
	-- it will never actually show up. This makes it a lot easier to shrink and
	-- move the lines around
	local difference = Vector2.new(55, 40)
	local line_colour = Color3.fromRGB(0, 0, 0)
	local text_size = 12

	do
		local curr_pos = 0
		local curr_value = 0
		local offset = DEFAULT_TEXTLABEL_SIZE.Y / 2
		for i = 1, MAXIMUM_LINES_IN_FRAME do
			local render = Instance.new("Frame")
			render.Name = `H_LINE_{i}`
			render.Size = UDim2.new(1, 0, 0, 1)
			render.BorderSizePixel = 0
			render.BackgroundColor3 = line_colour
			render.Position = UDim2.fromOffset(0, v_line_sz.Y - curr_pos)
			local label = Instance.new("TextLabel")
			label.Name = `H_LABEL_{i}`
			label.Size = utility.to_udim2(label_size)
			label.Position = UDim2.fromOffset(0, v_label_sz.Y - curr_pos - offset * 2)
			label.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
			label.BackgroundTransparency = 1
			label.BorderSizePixel = 0
			label.TextSize = text_size
			label.Text = `{curr_value}`

			render.Parent = v_line_frame
			label.Parent = v_label_frame

			local line: Line = {
				render = render,
				position = v_line_sz.Y - curr_pos,
				value = curr_value,
				label = label,
			}
			table.insert(h_lines, line)
			curr_pos += difference.Y
			curr_value += 1
		end
	end

	do
		local curr_pos = 0
		local curr_value = 0
		for i = 1, MAXIMUM_LINES_IN_FRAME do
			local render = Instance.new("Frame")
			render.Name = `V_LINE_{i}`
			render.Size = UDim2.new(0, 1, 1, 0)
			render.BorderSizePixel = 0
			render.BackgroundColor3 = line_colour
			render.Position = UDim2.fromOffset(curr_pos, 0)
			local label = Instance.new("TextLabel")
			label.Name = `V_LABEL_{i}`
			label.Size = utility.to_udim2(label_size)
			label.Position = UDim2.fromOffset(curr_pos, 0)
			label.BackgroundTransparency = 1
			label.BorderSizePixel = 0
			label.TextSize = text_size
			label.Text = `{curr_value}`

			render.Parent = h_line_frame
			label.Parent = h_label_frame

			local line: Line = {
				render = render,
				position = curr_pos,
				value = curr_value,
				label = label,
			}
			table.insert(v_lines, line)
			curr_pos += difference.X
			curr_value += 1
		end
	end

	local count = Vector2.new(0, 0)
	calculate_new_line_values(h_lines, count.X)
	calculate_new_line_values(v_lines, count.Y)
	print(v_lines)

	local function can_decrement(diff: number, decrement_by: number, min_diff: number): boolean
		return (diff - decrement_by) >= min_diff
	end

	local function can_increment(diff: number, increment_by: number, max: number): boolean
		return (diff + increment_by) <= max
	end

	local function move_left(shiftamount: number): ()
		assert(false, "--//TODO: Work on move_left function")
	end

	local function move_right(shiftamount: number): ()
		local size = utility.get_table_size(v_lines)
		if size < 1 then
			return
		end

		for i = 1, size do
			v_lines[i].position -= shiftamount
		end

		local first = v_lines[1]
		local last = v_lines[size]

		if first.position < 0 then
			local removed = table.remove(v_lines, 1) :: Line
			local newpos = last.position + difference.X
			local newval = calculate_new_value(first.value, count.X, size)
			removed.position = newpos
			removed.value = newval
			table.insert(v_lines, removed)
		end
	end

	local function move_up(shiftamount: number): ()
		local size = utility.get_table_size(h_lines)
		if size < 1 then
			return
		end

		for i = size, 1, -1 do
			h_lines[i].position += shiftamount
		end

		local first = h_lines[1]
		local last = h_lines[size]
		local x_max_pos = v_line_sz.Y --//TODO: we need to keep track of this value..

		if first.position > x_max_pos then
			local removed = table.remove(h_lines, 1) :: Line
			local newpos = last.position - difference.Y
			local newval = calculate_new_value(first.value, count.Y, size)
			removed.position = newpos
			removed.value = newval
			table.insert(h_lines, removed)
		end
	end

	local function move_down(shiftamount: number): ()
		local size = utility.get_table_size(h_lines)
		if size < 1 then
			return
		end

		for i = 1, size do
			h_lines[i].position -= shiftamount
		end

		local first = h_lines[size]
		local last = h_lines[1]

		if first.position < 0 then
			local removed = table.remove(h_lines, size) :: Line
			local newpos = last.position + difference.Y
			local newval = calculate_new_value(last.value, count.Y, 1, true)
			removed.position = newpos
			removed.value = newval
			table.insert(h_lines, 1, removed)
		end
	end

	local function update_render()
		do
			local size = utility.get_table_size(v_lines)
			for i = 1, size do
				local target_pos = v_lines[i].position
				local target_val = v_lines[i].value

				v_lines[i].render.Position = UDim2.new(0, target_pos, 0, 0)
				v_lines[i].label.Position = UDim2.new(0, target_pos, 0, 0)
				v_lines[i].label.Text = `{target_val}`
			end
		end

		do
			local size = utility.get_table_size(h_lines)
			for i = 1, size do
				local target_pos = h_lines[i].position
				local target_val = h_lines[i].value

				h_lines[i].render.Position = UDim2.new(0, 0, 0, target_pos)
				h_lines[i].label.Position = UDim2.new(0, 0, 0, target_pos)
				h_lines[i].label.Text = `{target_val}`
			end
		end
	end

	local function zoom_in(zoomamount: number)
		--[[
			The idea is that we try to increment our difference until we reach the
			minimum lines being rendered. Once we reach this point, we will reset the
			number of lines to our maximum defined lines and continue working our way
		]]

		-- Vertical lines zoom in
		do
			if can_increment(difference.X, zoomamount, 100) then
				difference += Vector2.new(zoomamount, 0)
			else
				-- we need to reset the value..
				difference = Vector2.new(20, difference.Y)
				count = Vector2.new(count.X - 1, count.Y)
				calculate_new_line_values(v_lines, count.X)
			end
			local size = utility.get_table_size(v_lines)
			local curr_pos = v_lines[1].position
			for i = 2, size do
				local new_pos = curr_pos + difference.X
				v_lines[i].position = new_pos
				curr_pos = new_pos
			end
		end

		-- Horizontal lines zoom in
		do
			if can_increment(difference.Y, zoomamount, 100) then
				difference += Vector2.new(0, zoomamount)
			else
				difference = Vector2.new(difference.X, 20)
				count = Vector2.new(count.X, count.Y - 1)
				calculate_new_line_values(h_lines, count.Y)
			end
			local size = utility.get_table_size(h_lines)
			local curr_pos = h_lines[1].position
			for i = 2, size do
				local new_pos = curr_pos - difference.Y
				h_lines[i].position = new_pos
				curr_pos = new_pos
			end
		end
	end

	local function zoom_out(zoomamount: number)
		--[[
			The idea is that we try to decrement our difference until we reach the
			maximum lines being rendered. Once we reach this point, we will reset the
			number of lines to our minimum defined lines and continue working our way
		]]

		-- Vertical lines zoom out
		do
			if can_decrement(difference.X, zoomamount, 20) then
				difference -= Vector2.new(zoomamount, 0)
			else
				-- we need to reset the value..
				difference = Vector2.new(100, difference.Y)
			end
			local size = utility.get_table_size(v_lines)
			local curr_pos = v_lines[1].position
			for i = 2, size do
				local new_pos = curr_pos - difference.X
				v_lines[i].position = new_pos
				curr_pos = new_pos
			end
		end

		-- Horizontal lines zoom in
		do
			if can_decrement(difference.Y, zoomamount, 20) then
				difference -= Vector2.new(0, zoomamount)
			else
				difference = Vector2.new(difference.X, 100)
			end
			local size = utility.get_table_size(h_lines)
			local curr_pos = h_lines[1].position
			for i = 2, size do
				local new_pos = curr_pos + difference.Y
				h_lines[i].position = new_pos
				curr_pos = new_pos
			end
		end
	end

	return {
		_graph = basegraph_frame,

		move_left = move_left,
		move_right = move_right,
		move_up = move_up,
		move_down = move_down,

		zoom_in = zoom_in,
		zoom_out = zoom_out,

		update_render = update_render,
	}
end

return basegraph
