defmodule WorkerApp do

	use Application

	def start(_type, _args) do
		
		import Application
		
		max_entry_count = get_env(:worker, :max_entry_count) 
		
		children = [
			Supervisor.Spec.worker(Worker, [max_entry_count])
		]

		opts = [
			strategy: :one_for_one,
			name: KVStore.WorkerSupervisor
		]

		Supervisor.start_link(children, opts)

	end

end
