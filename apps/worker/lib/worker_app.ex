defmodule WorkerApp do

	use Application
	
	require Logger

	def start(_type, _args) do
		
		WorkerSupervisor.start_link(
			Application.get_env(:worker, :max_entry_count)
		)

	end

end
