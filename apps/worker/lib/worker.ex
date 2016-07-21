defmodule Worker do
	use GenServer
	import GenServer

	def start_link(max_entry_count) do
		start_link(WorkerImpl, max_entry_count, [name: :data_worker])
	end

	def put(worker, key, value)  do
		call(worker, {:put, key, value})
	end

	def get(worker, key) do
		call(worker, {:get, key})
	end

	def delete(worker, key) do
		call(worker, {:delete, key})
	end

	# def filter(worker, operator, value) do
	# 	call(worker, {:filter, operator, value})
	# end

end
