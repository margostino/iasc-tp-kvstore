
defmodule KVStore do
	
	import Application

	@spec put(key :: binary, value :: binary) :: 
		{:ok, data :: term} | 
		{:error, {type :: atom, info :: term}} 
	def put(key, value) do
		
		case [valid_key?(key), valid_value?(value)] do
			
		   [true, true] ->
		   		send_to_worker(worker(key), :put, [key, value])		  
		   [false, true] -> 
		    	{:error, {:bad_args, %{key: key}}}
		   [true, false] -> 
		    	{:error, {:bad_args, %{value: value}}}
  		   [false, false] -> 
		   		{:error, {:bad_args, %{key: key, value: value}}}
		   		
		end
		
	end
	
	@spec get(key :: binary) ::
		{:ok, %{key: key :: binary, value: value :: binary}} | 
		{:error, {type :: atom, info :: term}} 
	def get(key) do
		
		if valid_key?(key) do
			send_to_worker(worker(key), :get, [key])
		else
			{:error, {:bad_args, %{key: key}}}
		end

	end 

	@spec delete(key :: binary) ::
		{:ok, %{key: key :: binary}} | 
		{:error, {type :: atom, info :: term}} 
	def delete(key) do

		if valid_key?(key) do
		  send_to_worker(worker(key), :delete, [key])
		else
		  {:error, {:bad_args, %{key: key}}}
		end

	end
	
	@spec values_gt(value :: binary) :: 
		{:ok, [val :: binary]} |
		{:error, {type :: atom, info :: term}} 
	def values_gt(value) do
		
		if valid_value?(value) do
			get_and_build({:values_gt, value}) 
		else
		  	{:error, {:bad_args, %{value: value}}}
		end
		
	end 
	
	@spec values_gte(value :: binary) :: 
		{:ok, [val :: binary]} |
		{:error, {type :: atom, info :: term}} 
	def values_gte(value) do

		if valid_value?(value) do
			get_and_build({:values_gte, value}) 
		else
		  	{:error, {:bad_args, %{value: value}}}
		end
		
	end 
	
	@spec values_lt(value :: binary) :: 
		{:ok, [val :: binary]} |
		{:error, {type :: atom, info :: term}} 
	def values_lt(value) do

		if valid_value?(value) do
			get_and_build({:values_lt, value}) 
		else
		  	{:error, {:bad_args, %{value: value}}}
		end
		
	end 
	
	@spec values_lte(value :: binary) :: 
		{:ok, [val :: binary]} |
		{:error, {type :: atom, info :: term}} 
	def values_lte(value) do

		if valid_value?(value) do
			get_and_build({:values_lte, value}) 
		else
		  	{:error, {:bad_args, %{value: value}}}
		end
		
	end 

	@spec keys() ::
		{:ok, [val :: binary]} | 
		{:error, {type :: atom, info :: term}} 
	def keys() do
		get_and_build({:keys}) 
	end

	@spec values() :: 
		{:ok, [val :: binary]} |
		{:error, {type :: atom, info :: term}} 
	def values() do
		get_and_build({:values}) 
	end
	
	@spec entries() :: 
		{:ok, [{key :: binary ,value :: binary}]} |
		{:error, {type :: atom, info :: term}} 
	def entries() do
		get_and_build({:entries}) 
	end
	

	defp send_to_worker(worker, func, args) do 

		try do 
			apply(Worker, func, [worker|args])
		catch 
			(:exit, {reason, _}) -> {:error, reason}
			(:error, {reason, _}) -> {:error, reason}
			(:error, reason) -> {:error, reason}
			(type, data) -> {:error, {type, inspect(data)}}
		end

	end


	defp get_and_build(msg) do 
		
		all_workers_do(msg) 
			|> build_response()
			
	end

	defp build_response({[r|replies], []}) do 
		{:ok, collect([r|replies])}
	end

	defp build_response({_, [f|fnodes]}) do 
		{:error, {:failed_nodes, [f|fnodes]}}
	end
	
	defp collect(replies) do 

		replies 
			|> Enum.map(fn({_, {:ok, sublist}}) -> sublist end) 
			|> List.flatten()

	end

	defp all_workers_do(msg) do 

		GenServer.multi_call(
			datanodes(),
			remote_worker_alias(),
			msg
		)

	end
	
	
	defp valid_key?(key) do
		is_binary(key) and (byte_size(key) <= max_key_size())
	end
	
	defp valid_value?(value) do
		is_binary(value) and (byte_size(value) <= max_value_size())
	end

	defp worker(key) do
		Enum.at(all_workers(), :erlang.phash2(key, length(all_workers())))
	end
	
	defp all_workers() do 
		Enum.map(datanodes(), fn(dn) -> {remote_worker_alias(), dn} end)
	end 

	defp remote_worker_alias() do
		get_env(:store, :remote_worker_alias)
	end

	defp datanodes() do
		get_env(:store, :datanodes)
	end
	
	defp max_key_size() do
		get_env(:store, :max_key_size)		
	end
	
	defp max_value_size() do
		get_env(:store, :max_value_size)		
	end


end
