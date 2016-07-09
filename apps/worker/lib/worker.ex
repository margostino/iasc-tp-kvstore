defmodule KVStore.Worker do

  use GenServer

  ########### public api ########################

  
  def start_link() do 
    GenServer.start_link(KVStore.WorkerImpl, [], [name: __MODULE__])
  end

  def put(worker, key, value)  do
    GenServer.call(worker, {:put, key, value})
  end

  def get(worker, key) do
    GenServer.call(worker, {:get, key})
  end

  def delete(worker, key) do
    GenServer.call(worker, {:delete, key})  
  end

  def filter(worker, operator, value) do
    GenServer.call(worker, {:filter, operator, value})
  end

  def keys(worker) do
    GenServer.call(worker, {:keys})
  end

  def values(worker) do
    GenServer.call(worker, {:values})
  end

end



