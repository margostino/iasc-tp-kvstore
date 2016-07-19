import KVDataStore

defmodule KVData do
  @moduledoc """
  Nodo de datos para la KVStore
  """
  use GenServer
  require Logger

  @doc "stating up the server"
  def start_link do
    Logger.info "Starting server"
    GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
  end

  @doc "stopping the server"
  def stop() do
    GenServer.cast(:NAME, :stop)
  end

  @doc "handle cast is only a async call that can be received or not by the gen server. In this case the server should always avoid returning anything. In this case we are using create_table for didactic purposes"
  def handle_cast({:create_table}, state) do
    KVDataStore.new_table()
    {:noreply, state}
  end

  def handle_cast({:delete, name}, state) do
    KVDataStore.delete(name)
    {:noreply, state}
  end

  def handle_call({:is_table_defined, table_name}, _from, state) do
    case KVDataStore.is_table_defined(table_name) do
      {:error, :none_found} -> {:reply, {:error, :none_found}, state}
      {_, x} ->   {:reply, x, state}
    end
  end

  def handle_call({:put, key, value}, _from,  state) do
    {:reply, KVDataStore.put(key, value), state}
  end

  def handle_call({:get, name}, _from,  state) do
    case KVDataStore.get(name) do
      {:error, _} -> {:reply, {:error, :failed_get_ets}, state}
      {:ok, value} -> {:reply, value, state}
      {_ , _} -> {:reply, {:error, :unexpected_error}, state}
    end
  end

  def handle_call({:update, key, value}, _from, state) do
    case KVDataStore.update(key, value) do
      {:error, :not_found} -> {:reply, :failed_update_ets, state}
      {:ok, _} -> {:reply, :succesful_update, state}
    end
  end

  def handle_call({:filter, value, operator}, _from, state) do
    case KVDataStore.filter(value, operator) do
      {:error, _} -> {:reply, {:error, :not_found}, state}
      {:ok, results} -> {:reply, {:ok, results}, state}
    end
  end

  def handle_call({:values}, _from, state) do
    case KVDataStore.values() do
      {:error, _} -> {:reply, :not_found, state}
      {:ok, results} -> {:reply, results, state}
    end
  end

  def handle_call({:keys}, _from, state) do
    case KVDataStore.keys() do
      {:error, _} -> {:reply, :not_found, state}
      {:ok, results} -> {:reply, results, state}
    end
  end

  def handle_info(msg, state) do
    Logger.info "Message not understood :( #{inspect msg}"
    {:noreply, state}
  end
end
