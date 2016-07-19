defmodule ListSearch do
  def search_pattern([], _) do
    {:error, :none_found}
  end

  def search_pattern([x|xs], element_atom) do
    case x == element_atom do
      true -> {:ok, x}
      false -> search_pattern(xs, element_atom)
    end
  end
end

defmodule KVDataStore do
  @moduledoc "Api del Nodo de datos para la KVStore  require Logger"
  require Logger

  def new_table(table_name) do
    :ets.new(table_name, [:named_table, :private, read_concurrency: true])
  end

  def is_table_defined(table_name) do
    ListSearch.search_pattern(:ets.all(),table_name)
  end

  @doc "Obtiene el valor a partir de una clave"
  def get(table, key) do
    Logger.info "GET: #{key}"
    case :ets.lookup(table, key) do
	[{_key, value}] -> {:ok, value}
	[] -> {:error, :not_found}
    end
  end

  @doc "Agrega (o reemplaza si ya existe) un valor dada una clave"
  def put(table, key, value) do
    Logger.info "PUT: #{key},#{value}"
    :ets.insert(table, {key, value})
  end

  @doc "Borra un valor a partir de la clave"
  def delete(table, key) do
    Logger.info "DELETE: #{key}"
    :ets.match_delete(table, {key, :_})
  end

  @doc "Actualiza un valor a partir de la clave"
  def update(table, key, new_value) do
    Logger.info "UPDATE: #{key},#{new_value}"
    case :ets.lookup(table, key) do
    	[{_key, _}] -> delete(table, key)
			   put(table, key, new_value)
	    [] -> {:error, :not_found}
    end
  end

  """
  Validations
  """

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
