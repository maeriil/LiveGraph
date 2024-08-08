local runservice = game:GetService("RunService")
local utility = require(script.Parent.Parent.utility)

export type BulletGraphProps = {
	--//TODO: Work on the vertical orientation
	orientation: "horizontal",

	title: string,
	desc: string?,

	max_scale_value: number,

	qualitative_range: { number },
	qualitative_range_colour: { Color3 },

	target_value: number,

	-- Graph properties
	size: Vector2,
	hide_label: boolean?,
	should_tilt: boolean?,
	hide_title: boolean?,

	event: RBXScriptSignal,
}

export type BulletGraph = {
	graph: Frame,

	start: (callback: () -> number) -> (),
	stop: () -> (),
}

return function(props: BulletGraphProps): BulletGraph
	-- Do some validations on the data first
	do
		-- They both must be same size since they are used together
		local sz1 = #props.qualitative_range
		local sz2 = #props.qualitative_range_colour
		assert(sz1 == sz2, "Qualitative range and Qualitative range colour both must be same size")

		for i, v in props.qualitative_range do
			assert(
				v > 0 and v <= props.max_scale_value,
				`qualitative range value {v} is not within the range (0, {props.max_scale_value}]`
			)
		end
	end

	local graph_container = Instance.new("Frame")
	graph_container.Transparency = 1
	graph_container.AutomaticSize = Enum.AutomaticSize.XY
	-- graph_container.Size = utility.to_udim2(props.size)

	local graph_background = Instance.new("Frame")
	graph_background.Size = utility.to_udim2(props.size)
	graph_background.BorderSizePixel = 0
	graph_background.Transparency = 1
	graph_background.Parent = graph_container

	local prev_pos = 0
	local prev = 0
	for i, v in props.qualitative_range do
		local range_colour = props.qualitative_range_colour[i]
		local range_size = UDim2.new((v - prev) / props.max_scale_value, 0, 1, 0)
		local range_frame = Instance.new("Frame")
		range_frame.Position = UDim2.new(prev_pos, 0, 0, 0)
		range_frame.Size = range_size
		range_frame.BackgroundColor3 = range_colour
		range_frame.BorderSizePixel = 0
		range_frame.Parent = graph_background

		prev_pos = (v / props.max_scale_value)
		prev = v
	end

	local feature_measure = Instance.new("Frame")
	local feature_measure_size = 0.20
	feature_measure.Size = UDim2.new(0, 0, feature_measure_size, 0)
	feature_measure.Position = UDim2.new(0, 0, 0.5, 0)
	feature_measure.AnchorPoint = Vector2.new(0, 0.5)
	feature_measure.BorderSizePixel = 0
	feature_measure.Parent = graph_background

	local comparitive_measure = Instance.new("Frame")
	local comparitive_measure_size = 0.65
	comparitive_measure.Size = UDim2.new(0, 2, comparitive_measure_size, 0)
	comparitive_measure.Position = UDim2.fromScale(props.target_value / props.max_scale_value, 0.5)
	comparitive_measure.AnchorPoint = Vector2.new(0, 0.5)
	comparitive_measure.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	comparitive_measure.BorderSizePixel = 0
	comparitive_measure.Parent = graph_background

	local should_tilt = props.should_tilt or false
	local labels_container = Instance.new("Frame")
	local labels_container_size = if should_tilt then 64 else 42
	labels_container.Size = utility.to_udim2(Vector2.new(props.size.X, labels_container_size))
	labels_container.Position = utility.to_udim2(Vector2.new(0, props.size.Y))
	labels_container.BackgroundTransparency = 1
	labels_container.BorderSizePixel = 0
	labels_container.Parent = graph_container

	local num_of_labels_to_show = 5
	local labels = {}
	local diff = props.max_scale_value / (num_of_labels_to_show - 2)
	table.insert(labels, 0)

	for i = 1, num_of_labels_to_show - 2 do
		table.insert(labels, i * diff)
	end

	table.insert(labels, props.max_scale_value)
	local label_h_size = 64

	for i, v in labels do
		local line = Instance.new("Frame")
		line.Size = UDim2.new(0, 1, 0.3, 0)
		line.Position = UDim2.new(v / props.max_scale_value, 0, 0, 0)
		line.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		line.BorderSizePixel = 0
		line.Parent = labels_container

		local textlabel = Instance.new("TextLabel")
		textlabel.Position = UDim2.new(v / props.max_scale_value, 0, 1, 0)
		textlabel.Size = UDim2.new(0, label_h_size, 0.7, 0)
		textlabel.AnchorPoint = Vector2.new(0.5, 1)
		textlabel.BorderSizePixel = 0
		textlabel.BackgroundTransparency = 1
		textlabel.Text = utility.to_e_notation(v)
		textlabel.TextSize = 12
		textlabel.Rotation = if should_tilt then 45 else 0
		textlabel.Parent = labels_container
	end

	local _connection: RBXScriptConnection

	local size = 0
	local is_stepped = props.event == runservice.Stepped
	local function update_render(dt: number)
		local capped_value = math.min(size, props.max_scale_value)
		feature_measure.Size =
			UDim2.fromScale(capped_value / props.max_scale_value, feature_measure_size)
	end

	local function start(callback: () -> number)
		if _connection and _connection.Connected then
			return
		end

		local function go(dt: number)
			size = callback()
			update_render(dt)
		end

		local function stepped_go(_: number, dt: number)
			size = callback()
			update_render(dt)
		end

		_connection = if is_stepped then props.event:Connect(stepped_go) else props.event:Connect(go)
	end

	local function stop()
		if not _connection or _connection.Connected then
			return
		end

		_connection:Disconnect()
	end

	return {
		graph = graph_container,
		start = start,
		stop = stop,
	}
end
