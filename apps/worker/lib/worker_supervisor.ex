defmodule WorkerSupervisor do
	
	use Supervisor
	
	require Logger
	
	def start_link(max_entry_count) do
		Supervisor.start_link(__MODULE__, max_entry_count, [name: __MODULE__])
	end
	
	def init(max_entry_count) do
		
		entries = :ets.new(:dummy, [:set, :public])
		
		children = [
			worker(Worker, [entries, max_entry_count], [restart: :transient])
		]

		supervise(children, [strategy: :one_for_one])

	end
	
end
