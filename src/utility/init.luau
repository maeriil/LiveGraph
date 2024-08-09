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

--[=[
  Convert a number into a small and legible string format.\
  If num >= 1000, we will convert it to scientific format\
  @param number num number to format to string
  @return string the formatted number as string
]=]
local function conv_number(num: number): string
	local n = math.abs(num)

	if n >= 1000 or (n ~= 0 and n < 1 / 100) then
		return string.format("%.1e", n)
	elseif n % 1 ~= 0 then
		return string.format("%.2f", n)
	else
		return tostring(n)
	end
end

--//TODO: We want to change {num}e+DIGITS to {num}E{Digit}
local function to_e_notation(num: number): string
	local n = math.abs(num)
	if n ~= 0 and (n > 10000 or n < 1 / 100) then
		local e_notation = string.format("%.2e", num)

		local base, exponent = e_notation:match("^(.*)e([+-]?%d+)$")
		assert(exponent and base, "Exponent and Base cannot be nil")

		local sign = exponent:sub(1, 1)
		if sign == "+" or sign == "-" then
			exponent = sign .. exponent:sub(2):gsub("^0+", "")
		else
			exponent = exponent:gsub("^0+", "")
		end

		-- Remove the '+' sign if the exponent is positive
		if sign == "+" then
			exponent = exponent:sub(2)
		end

		return base .. "E" .. exponent
	end

	return string.format("%.2f", num)
end

return {
	to_udim2 = to_udim2,
	get_table_size = table_size,
	conv_number = conv_number,
	to_e_notation = to_e_notation,

	NAN = NAN,
}
