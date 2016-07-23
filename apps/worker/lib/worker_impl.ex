
defmodule WorkerImpl do

	require Logger

	@filters [{:values_gt,:>},{:values_gte,:>=},{:values_lt,:<},{:values_lte,:<=}]
	@table_name :data_table

	def init(max_entry_count) do
		entries = :ets.new(@table_name, [:named_table, read_concurrency: true])
		{:ok, {entries, max_entry_count}}
	end

	def handle_call({:put, key, value}, _, state) do
		unless full?(state) do
			:ets.insert(@table_name,{key, value})
			success = {:ok, %{key: key, value: value}}
			{:reply, success, state}
		else
			failure = {:error,
			{:no_space, %{node: node(), entries: entry_count()}}}
			{:reply, failure, state}
		end
	end

	def handle_call({:get, key}, _, state) do
		case lookup(@table_name, key) do
			{:ok, value} ->
				{:reply, {:ok, %{key: key, value: value}}, state}
			:error ->
				{:reply, {:error, {:key_not_found, %{key: key}}}, state}
		end
	end

	def handle_call({:delete, key}, _,  state) do
		case lookup(@table_name, key) do
			{:ok, _} ->
				:ets.delete(@table_name, key)
				{:reply, {:ok, %{key: key}}, state}
			:error ->
				{:reply, {:error, {:key_not_found, %{key: key}}}, state}
		end
	end

	def handle_call({:keys}, _, state) do
		{:ok, keys} = keys()
		{:reply, {:ok, keys}, state}
	end

	def handle_call({:values}, _, state) do
		{:ok, values} = values()
		{:reply, {:ok, values}, state}
	end

	def handle_call({filter_selector, value}, _, state) do
	 	{:reply, {:ok, filter(value, filter_selector)}, state}
	end

	def handle_info(msg, state) do
		Logger.info(~s(Message #{inspect msg} not understood :())
		{:noreply, state}
	end

	def filter(value, operator) do
		 :ets.select(@table_name, [{{:"$1",:"$2"},
		 [{@filters[operator], :"$2", value}], [:"$2"]}])
	end

	def keys(:"$end_of_table", keysResult) do
		keysResult
	end

	def keys(currKey, keysResult) do
		keys(:ets.next(@table_name, currKey), [currKey|keysResult])
	end

	def keys() do
		{:ok, keys(:ets.first(@table_name), [])}
	end

	def values(:"$end_of_table", valuesResult) do
		valuesResult
	end

	def values(currKey, valuesResult) do
		[{_, value}] = :ets.lookup(@table_name, currKey)
		values(:ets.next(@table_name, currKey), [value|valuesResult])
	end

	def values() do
		{:ok, values(:ets.first(@table_name), [])}
	end

	def lookup(server, key) when is_atom(server) do
			case :ets.lookup(server, key) do
			 [{^key, value}] -> {:ok, value}
			 [] -> :error
		 end
	 end

	defp full?({_, max_entry_count}) do
		not(entry_count() < max_entry_count)
	end

	defp entry_count do
		{_, size} = List.keyfind(:ets.info(@table_name), :size, 0)
		size
	end
end
