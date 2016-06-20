defmodule KVStore do
  use GenServer

  ## Client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  def put(server, key, value) do
    case (validate(key, value)) do
      {:error, reasons} -> {:error, reasons}
      :ok ->
        GenServer.cast(server, {:put, key, value})
    end
  end

  def delete(server, key) do
    GenServer.cast(server, {:delete, key})
  end

  def break(server) do
    Process.exit(server, :shutdown)
  end

  # Operators: gt, lt, gte, lte
  def filter(server, operator, value) do
    operator = String.downcase(operator)
    if (validate(operator)) do
      GenServer.call(server, {:filter, value, operator})
    else
      {:error, "Operator should be: gt, gte, lt or lte"}
    end
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

  def handle_call({:filter, value, operator}, _from, state) do
    values = Map.values(state)
    results = Enum.filter(values, fn(x) -> compare().(x, value, operator) end)
    {:reply, {:ok, results}, state}
  end

  ## Private

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
    Enum.any?(operators, fn(x) -> x == operator end)
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
