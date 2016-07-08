defmodule KVStore.Api do
  use GenServer
  require Logger

  def start_link do
    Logger.info "Starting server"
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  ## Client API
  def get(key) do
    GenServer.call({:global, KVStore.Data}, {:get, key})
  end

  def keys() do
    GenServer.call({:global, KVStore.Data}, {:keys})
  end

  def values() do
    GenServer.call({:global, KVStore.Data}, {:values})
  end

"""
     case (validate(key, value)) do
      {:error, reasons} -> {:error, reasons}
      :ok ->
"""
"""
    end
"""

  def put(key, value) do
        GenServer.cast({:global, KVStore.Data}, {:put, key, value})
  end

  def delete(key) do
    GenServer.cast({:global, KVStore.Data}, {:delete, key})
  end

  def break() do
    Process.exit({:global, KVStore.Data}, :shutdown)
  end


"""
    case (validate(operator)) do
      {:error, reasons} -> {:error, reasons}
      :ok ->
"""
"""
    end
"""

  def filter(operator, value) do
    operator = String.downcase(operator)
        GenServer.call({:global, KVStore.Data}, {:filter, value, operator})
  end

  def handle_info(msg, state) do
    IO.puts "Message not understood :( #{inspect msg}"
    {:noreply, state}
  end

  ## Private -------------------------------------------------------------------
  #-----------------------------------------------------------------------------

end
