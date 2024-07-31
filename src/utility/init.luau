--[=[
  NaN values which we need to represent in our graph. Since the user can input
  any kind of values, when we see a NaN value, we instead insert this symbol.
  Then when we draw the value in the graph, we can create a large vertical red line
  so we can easily see that our graph has nan values
]=]
export type NAN = "$$$NAN"
local NAN: NAN = "$$$NAN"

--[=[
  Get a size of table including dictionaries or mixed tables
  @param { T } t Table to get the size of
  @return number The size of the table
]=]
local function table_size<T>(t: { T }): number
	local size = 0
	for _, _ in t do
		size += 1
	end
	return size
end

--[=[
  Convert a vector2 value into a UDim2 format using offset values only
  @param Vector2 v The vector2 value to convert to UDim2
  @param UDim2 The new converted value
]=]
local function to_udim2(v: Vector2): UDim2
	return UDim2.fromOffset(v.X, v.Y)
end

return {
	to_udim2 = to_udim2,
	get_table_size = table_size,

	NAN = NAN,
}
