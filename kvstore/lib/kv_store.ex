defmodule KVStore do
  use Application
  require Logger

  def start(type, args) do
    import Supervisor.Spec, warn: false
    IO.puts "Parametros: #{args}"
    Logger.info("KVStore application in #{inspect type} mode")

    children = [
      worker(KVStore.Api, [{10,10,10}])
    ]

    opts = [strategy: :one_for_one, name: KVStore.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
