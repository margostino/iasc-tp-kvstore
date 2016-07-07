defmodule KVStore.Data do
  use GenServer
  require Logger

  def start_link do
    Logger.info "Starting server"
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  ## Client API
  def handle_call({:get, key}, _from, state) do
    Logger.info "GET: #{key}"
    map = Enum.into(state, %{})
    if Map.has_key?(map, key) do
      {:reply, {:ok, Map.get(map, key)}, state}
    else
      {:reply, {:ok, :not_found}, state}
    end
  end

  def handle_call({:keys}, _from, state) do
    map = Enum.into(state, %{})
    {:reply, {:ok, Map.keys(map)}, state}
  end

  def handle_call({:values}, _from, state) do
    map = Enum.into(state, %{})
    {:reply, {:ok, Map.values(map)}, state}
  end

  def handle_cast({:put, key, value}, state) do
    Logger.info "PUT: #{key},#{value}"
    map = Enum.into(state, %{})
    #{:noreply, Enum.into([], ["#{key}": value])}
    {:noreply, Enum.into([], Map.to_list(Map.put(map, key, value)))}
  end

  def handle_cast({:delete, key}, state) do
    {:noreply, Map.delete(Enum.into(state, %{}), key)}
  end

  def handle_call({:filter, value, operator}, _from, state) do
    values = Map.values(Enum.into(state, %{}))
    results = Enum.filter(values, fn(x) -> compare().(x, value, operator) end)
    {:reply, {:ok, results}, state}
  end

  def handle_info(msg, state) do
    IO.puts "Message not understood :("
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
