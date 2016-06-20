defmodule KVStore do
  use GenServer

  ## Client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  def getAll(server) do
    GenServer.call(server, {:getAll})
  end

  def put(server, key, value) do
    if !(is_bitstring(key) && is_bitstring(value)) do
      {:error, "Key/Value must be String"}
    else
      key_size = Application.get_env(:kvstore, :key_size)
      value_size = Application.get_env(:kvstore, :value_size)
      if (String.length(key) <= key_size && String.length(value) <= value_size) do
        GenServer.cast(server, {:put, key, value})
      else
        {:error, "Key/Value wrong size"}
      end
    end
  end

  def delete(server, key) do
    GenServer.cast(server, {:delete, key})
  end

  def break(server) do
    Process.exit(server, :shutdown)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get, key}, _from, state) do
    if Map.has_key?(state, key) do
      {:reply, {:ok, Map.get(state, key)}, state}
    else
      {:reply, {:ok, :not_found}, state}
    end
  end

  def handle_call({:getAll}, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_cast({:delete, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  def handle_info(msg, state) do
    IO.puts "Message not understood :("
    {:noreply, state}
  end
end
