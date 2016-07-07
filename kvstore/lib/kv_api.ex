defmodule KVStore.Api do
  use GenServer
  require Logger

  def start_link do
    Logger.info "Starting server"
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  ## Client API
  def get(key) do
    GenServer.call({:global, __MODULE__}, {:get, key})
  end

  def keys() do
    GenServer.call({:global, __MODULE__}, {:keys})
  end

  def values() do
    GenServer.call({:global, __MODULE__}, {:values})
  end

  def put(key, value) do
    case (validate(key, value)) do
      {:error, reasons} -> {:error, reasons}
      :ok ->
        GenServer.cast({:global, __MODULE__}, {:put, key, value})
    end
  end

  def delete(key) do
    GenServer.cast({:global, __MODULE__}, {:delete, key})
  end

  def break() do
    Process.exit({:global, __MODULE__}, :shutdown)
  end

  # Operators: gt, lt, gte, lte
  def filter(operator, value) do
    operator = String.downcase(operator)
    case (validate(operator)) do
      {:error, reasons} -> {:error, reasons}
      :ok ->
        GenServer.call({:global, __MODULE__}, {:filter, value, operator})
    end
  end

  ## Server Callbacks ----------------------------------------------------------
  #-----------------------------------------------------------------------------

  def handle_call({:get, key}, _from, state) do
    {:reply, {:ok, KVStore.Data.get(key)}, state}
  end

  def handle_call({:keys}, _from, state) do
    {:reply, {:ok, KVStore.Data.keys()}, state}
  end

  def handle_call({:values}, _from, state) do
    {:reply, {:ok, KVStore.Data.values()}, state}
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, KVStore.Data.put(key, value)}
  end

  def handle_cast({:delete, key}, state) do
    {:noreply, KVStore.Data.delete(key)}
  end

  def handle_call({:filter, value, operator}, _from, state) do
    {:reply, {:ok, KVStore.Data.filter(value, operator)}, state}
  end

  def handle_info(msg, state) do
    IO.puts "Message not understood :("
    {:noreply, state}
  end

  ## Private -------------------------------------------------------------------
  #-----------------------------------------------------------------------------

end
