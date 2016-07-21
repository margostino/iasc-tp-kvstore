
defmodule WorkerImpl do

	require Logger
	
	@filters [:values_gt, :values_gte, :values_lt, :values_lte]
	
	def init(max_entry_count) do
		{:ok, %{entries: %{}, max_entry_count: max_entry_count}}
	end 

	def handle_call({:put, key, value}, _, state) do
		
		unless full?(state) do
			
			success = {:ok, 
				%{key: key, value: value}
			} 
			
			{:reply, success, add_entry(state, key, value)}
			
		else
			
			failure = {:error,
				{:no_space, %{node: node(), entries: entry_count(state)}}
			}
			
			{:reply, failure, state}
			
		end
		
	end

	def handle_call({:get, key}, _, state) do

		case get_entry(state, key) do 

			{:ok, value} ->
				{:reply, {:ok, %{key: key, value: value}}, state}

			:error ->
				{:reply, {:error, {:key_not_found, %{key: key}}}, state}

		end		

	end

	def handle_call({:delete, key}, _,  state) do

		case get_entry(state, key) do 

			{:ok, _} -> 
				{:reply, {:ok, %{key: key}}, remove_entry(state, key)}

			:error ->
				{:reply, {:error, {:key_not_found, %{key: key}}}, state}

		end 

	end
	
	def handle_call({filter_selector, value}, _, state) 
		when filter_selector in @filters do		
		
		{:reply, {:ok, do_filter(state, filter_selector, value)}, state}
		
	end

	def handle_call({:keys}, _, state) do
		{:reply, {:ok, Map.keys(state.entries)}, state}
	end

	def handle_call({:values}, _, state) do
		{:reply, {:ok, Map.values(state.entries)}, state}
	end

	def handle_call({:entries}, _, state) do
		{:reply, {:ok, Map.to_list(state.entries)}, state}
	end


	def handle_info(msg, state) do

		Logger.info(~s(Message #{inspect msg} not understood :())

		{:noreply, state}

	end
	
	defp do_filter(state, selector, value) do
		
		state.entries 
			|> Map.values()
			|> Enum.filter(filter_from(selector, value))
		
	end
	
	defp filter_from(:values_gt, value) do 
		fn(x) -> x > value end
	end
	
	defp filter_from(:values_gte, value) do 
		fn(x) -> x >= value end
	end

	defp filter_from(:values_lt, value) do 
		fn(x) -> x < value end
	end

	defp filter_from(:values_lte, value) do 
		fn(x) -> x <= value end
	end

	
	defp add_entry(state, key, value) do 
		%{state | entries: Map.put(state.entries, key, value)}
	end 

	defp remove_entry(state, key) do 
		%{state | entries: Map.delete(state.entries, key)}
	end 

	defp get_entry(state, key) do 
		Map.fetch(state.entries, key)
	end 

	defp full?(state) do 
		not(entry_count(state) < state.max_entry_count)
	end

	defp entry_count(state) do 
		map_size(state.entries)
	end


end
