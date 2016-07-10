
defmodule WorkerImpl do

	require Logger
	
	import Map 
	import Enum

  ########################### genserver callbacks ###########################

	def init([]) do 

		import String

		Logger.info(~s(-- starting worker with pid #{downcase(inspect self())} --))

		{:ok, new()}

	end 

	def handle_call({:get, key}, from, map) do

		Logger.info("handling get for key: #{inspect key}")

		if has_key?(map, key) do
			{:reply, {:ok, get(map, key)}, map}
		else
			{:reply, {:ok, :not_found}, map}
		end

	end


	def handle_call({:put, key, value}, from, map) do

		Logger.info("handling put for #{inspect key}, #{inspect value}")

		{:reply, {:ok, key}, put(map, key, value)} 

	end

	def handle_call({:delete, key}, from,  map) do

		Logger.info("handling delete for key: #{inspect key}")

		case (newmap = delete(map, key)) do 

			^map -> {:reply, {:ok, :no_modifications}, newmap}
			_ -> {:reply, {:ok, key}, newmap}

		end    

	end

	def handle_call({:filter, operator, value}, from, map) do

		Logger.info("handling filter with op: #{inspect operator} and value: #{inspect value}")

		result = map 
			|> values()
			|> filter(fn(x) -> compare().(x, operator, value) end)

		{:reply, {:ok, result}, map}

	end

	def handle_call({:keys}, from, map) do

		{:reply, {:ok, keys(map)}, map}

	end

	def handle_call({:values}, from, map) do

		{:reply, {:ok, values(map)}, map}

	end


	def handle_info(msg, state) do

		Logger.info("Message #{inspect msg} not understood :(")

		{:noreply, state}

	end

	defp compare() do
		f = fn
		a, operator, b when operator == "gt"  -> a >  b
		a, operator, b when operator == "gte" -> a >= b
		a, operator, b when operator == "lt"  -> a <  b
		a, operator, b when operator == "lte" -> a <= b
	end
	f
	end


	defp validateType(val) do
	if !(is_bitstring(val)) do
		:error
	else
		:ok
	end
	end

	defp validateSize(val, size) do
	if !(String.length(val) <= size) do
		:error
	else
		:ok
	end
	end

	defp validate(operator) do
	operators = ["gt", "gte", "lt", "lte"]
	if (any?(operators, fn(x) -> x == operator end)) do
		:ok
	else
		{:error, "Operator should be: gt, gte, lt or lte"}
	end
	end

	defp validate(key, value) do

	key_size = Application.get_env(:worker, :max_key_size)
	value_size = Application.get_env(:worker, :max_value_size)

	errors = []

	#Validate KEY
	case validateType(key) do
		:error ->
			errors = ["Key must be a string" | errors]
			:ok ->
				case validateSize(key, key_size) do
					:error ->
						errors = ["Wrong key size. Size must be #{inspect key_size}" | errors]
						:ok -> 
							"nothing"
						end
					end

	#Validate VALUE
	case validateType(value) do
		:error -> errors = into(errors, ["Value must be String"])
		:ok -> case validateSize(value, value_size) do
			:error ->
				errors = ["Value wrong size. Size must be #{value_size}" | errors]
				:ok -> "nothing"
			end
		end

		if (length(errors) > 0) do
			{:error, errors}
		else
			{:ok}
		end

	end

	end

