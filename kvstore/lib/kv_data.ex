defmodule KVStore.Data do
  @moduledoc """
  Nodo de datos para la KVStore
  """
  use GenServer
  require Logger

  def start_link do
    Logger.info "Starting server"
    create()
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  def create() do
    names = :ets.new(:data_table, [:named_table, :private, read_concurrency: true])
    refs  = %{}
    IO.puts "#{inspect names} #{inspect refs}"
  end

  @doc """
  Agrega (o reemplaza si ya existe) un valor dada una clave
  """
  def handle_cast({:put, key, value}, state) do
    Logger.info "PUT: #{key},#{value}"
    :ets.insert(:data_table, {key, value})
    {:noreply, state}
  end

  @doc """
  Borra un valor a partir de la clave
  """
  def handle_cast({:delete, key}, state) do
    :ets.delete(:data_table, key)
    {:noreply, state}
  end

  ## Client API
  def handle_call({:get, key}, _from, state) do
    Logger.info "GET: #{key}"
    case :ets.member(:data_table, key) do
      true -> {:reply, {:ok, :ets.lookup(:data_table, key)}, state}
      false -> {:reply, {:ok, :not_found}, state}
    end
  end

  @doc """
  Obtiene la lista de claves guardadas
  """
  def handle_call({:keys}, _from, state) do
      {:reply, {:ok, keys(:ets.first(:data_table), [])}, state}
  end

  @doc """
  Obtiene los valores que cumplen la condición de valor de referencia y de operador
  """
  def handle_call({:filter, value, operator}, _from, state) do
    results = :ets.select(:data_table, :ets.fun2ms(fn(x) -> compare().(x, value, operator) end))
    {:reply, {:ok, results}, state}
  end

  @doc """
  Obtiene la lista de valores guardados
  """
  def handle_call({:values}, _from, state) do
    {:reply, {:ok, values(:ets.first(:data_table), [])}, state}
  end

  def keys('$end_of_table', keysResult) do
    keysResult
  end

  def keys(currKey, keysResult) do
      nextKey = :ets.next(:data_table, currKey)
      keys(nextKey, [currKey|keysResult])
  end

  def values('$end_of_table', [valuesResult]) do
        valuesResult
  end

  def values(currKey, valuesResult) do
      nextKey = :ets.next(:data_table, currKey)
      values(nextKey, [:ets.lookup(:data_table, currKey)|valuesResult])
  end


  def handle_info(msg, state) do
    IO.puts "Message not understood :( #{inspect msg}"
    {:noreply, state}
  end

  defp compare() do
    f = fn
          a,b,operator when operator=="gt" -> a>b
          a,b,operator when operator=="gte" -> a>=b
          a,b,operator when operator=="lt" -> a<b
          a,b,operator when operator=="lte" -> a<=b
        end
    f
  end

  defp validateType(val) do
    if !(is_bitstring(val)) do
      :error
    else
      :ok
    end
  end

  defp validateSize(val, size) do
    if !(String.length(val) <= size) do
      :error
    else
      :ok
    end
  end

  defp validate(operator) do
    operators = ["gt", "gte", "lt", "lte"]
    if (Enum.any?(operators, fn(x) -> x == operator end)) do
      :ok
    else
      {:error, "Operator should be: gt, gte, lt or lte"}
    end
  end

  defp validate(key, value) do
    errors = []
    key_size = Application.get_env(:kvstore, :key_size)
    value_size = Application.get_env(:kvstore, :value_size)

    #Validate KEY
    case validateType(key) do
      :error ->
        errors = Enum.into(errors, ["Key must be String"])
      :ok ->
        case validateSize(key, key_size) do
          :error ->
            errors = Enum.into(errors, ["Key wrong size. Size must be #{key_size}"])
          :ok -> "nothing"
        end
    end

    #Validate VALUE
    case validateType(value) do
      :error ->
        errors = Enum.into(errors, ["Value must be String"])
      :ok ->
        case validateSize(value, value_size) do
          :error ->
            errors = Enum.into(errors, ["Value wrong size. Size must be #{value_size}"])
          :ok -> "nothing"
        end
    end

    if (Enum.count(errors)>0) do
      {:error, errors}
    else
      :ok
    end
  end
end
