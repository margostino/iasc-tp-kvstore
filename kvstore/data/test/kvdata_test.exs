defmodule KVDataTest do
    use ExUnit.Case
    @table_name :data_table

    setup do
      {:ok, key_value} = KVData.start_link
      {:ok, key_value: key_value}
    end


    test "Create table and check it exists", %{key_value: key_value} do
      GenServer.cast(key_value, {:create_table})
      assert GenServer.call(key_value, {:is_table_defined, @table_name}) == @table_name
      assert GenServer.call(key_value, {:is_table_defined, :undefined_table}) == {:error, :none_found}
    end

    test "Create table, put a value and retrieve it", %{key_value: key_value} do
      GenServer.cast(key_value, {:create_table})
      assert GenServer.call(key_value, {:is_table_defined, @table_name}) == @table_name
      assert GenServer.call(key_value, {:put, "a_value", "1"}) == true
      assert GenServer.call(key_value, {:get, "a_value"}) == "1"
    end

    test "Create table, put a value, retrieve it and then delete it", %{key_value: key_value} do
      GenServer.cast(key_value, {:create_table})
      assert GenServer.call(key_value, {:is_table_defined, @table_name}) == @table_name
      assert GenServer.call(key_value, {:put, "a_value", "1"}) == true
      assert GenServer.call(key_value, {:get, "a_value"}) == "1"
      GenServer.cast(key_value, {:delete, "a_value"})
      assert GenServer.call(key_value, {:get, "a_value"}) == {:error, :failed_get_ets}
    end

    test "Create table, put a value, update it", %{key_value: key_value} do
      GenServer.cast(key_value, {:create_table})
      assert GenServer.call(key_value, {:is_table_defined, @table_name}) == @table_name
      assert GenServer.call(key_value, {:put, "a_value", "1"}) == true
      GenServer.call(key_value, {:update, "a_value", "2"})
      assert GenServer.call(key_value, {:get, "a_value"}) == "2"
    end

    test "Create table, put values and get keys", %{key_value: key_value} do
      GenServer.cast(key_value, {:create_table})
      assert GenServer.call(key_value, {:keys}) == []
      assert GenServer.call(key_value, {:is_table_defined, @table_name}) == @table_name
      assert GenServer.call(key_value, {:put, "a_value", "1"}) == true
      assert GenServer.call(key_value, {:get, "a_value"}) == "1"

      assert GenServer.call(key_value, {:keys}) == ["a_value"]

      assert GenServer.call(key_value, {:put, "another_value", "2"}) == true
      assert GenServer.call(key_value, {:get, "another_value"}) == "2"

      keys = GenServer.call(key_value, {:keys})
      #{response, keys} = GenServer.call(key_value, {:keys})

      assert ListSearch.search_pattern(keys, "a_value") == {:ok, "a_value"}
      assert ListSearch.search_pattern(keys, "another_value") == {:ok, "another_value"}
    end

    test "Create table, put values and get values", %{key_value: key_value} do
      GenServer.cast(key_value, {:create_table})
      assert GenServer.call(key_value, {:values}) == []

      assert GenServer.call(key_value, {:is_table_defined, @table_name}) == @table_name
      assert GenServer.call(key_value, {:put, "a_value", "1"}) == true
      assert GenServer.call(key_value, {:get, "a_value"}) == "1"

      assert GenServer.call(key_value, {:values}) == ["1"]

      assert GenServer.call(key_value, {:put, "another_value", "2"}) == true
      assert GenServer.call(key_value, {:get, "another_value"}) == "2"

      values = GenServer.call(key_value, {:values})

      assert ListSearch.search_pattern(values, "1") == {:ok, "1"}
      assert ListSearch.search_pattern(values, "2") == {:ok, "2"}
    end
  end
