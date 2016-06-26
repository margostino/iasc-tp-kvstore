defmodule KVStore do
  use Application
  require Logger

  def start(type, _args) do
    import Supervisor.Spec, warn: false

    Logger.info("KVStore application in #{inspect type} mode")

    children = [
      worker(KVStore.Api, [])
    ]

    opts = [strategy: :one_for_one, name: KVStore.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
