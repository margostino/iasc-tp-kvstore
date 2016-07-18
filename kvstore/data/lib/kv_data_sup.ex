defmodule KVData.Supervisor do
  use Application
  use Supervisor
  require Logger

  ## Client API

  def start_link(server_name) do
    Logger.info("KVData application server name: #{inspect server_name}")
    Supervisor.start_link(__MODULE__, server_name)
  end

  ## Server Callbacks

  def init(server_name) do
   ets = :ets.new(:data_table, [:private, read_concurrency: true])
   #table = :ets.new(:server_ets, [:bag, :protected])
   #:dets.open_file(@dets_alias, [file: @name_dets_file, type: :set])

    children = [
      worker(KVData, [server_name, ets], restart: :transient),
    ]

    supervise(children, strategy: :one_for_one)
  end

end
