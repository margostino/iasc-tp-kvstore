defmodule KVStoreWorker do

  use Application

  def start(_type, _args) do

    children = [
      Supervisor.Spec.worker(KVStore.Worker, [])
    ]

    opts = [
      strategy: :one_for_one,
      name: KVStore.WorkerSupervisor
    ]
    
    Supervisor.start_link(children, opts)

  end

end
