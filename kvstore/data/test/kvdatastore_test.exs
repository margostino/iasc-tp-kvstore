defmodule ListSearchTest do
  use ExUnit.Case

  test "Search pattern on empty list" do
    list = []
    assert ListSearch.search_pattern(list, 2) == {:error, :none_found}
  end

  test "Search inexistent value on list" do
    list = [1,2,4,8,16,32]
    assert ListSearch.search_pattern(list, 31) == {:error, :none_found}
  end

  test "Search existent value on list" do
    list = [1,2,4,8,16,32]
    assert ListSearch.search_pattern(list, 4) == {:ok, 4}
  end

end

defmodule KVDataStoreTest do
  use ExUnit.Case

  test "add table and check if the tables are defined or not" do
    KVDataStore.new_table(:onetable)
    assert KVDataStore.is_table_defined(:onetable) == {:ok, :onetable}
    assert KVDataStore.is_table_defined(:some_table) == {:error, :none_found}
  end

  test "initialize, set 1 and get it" do
    KVDataStore.new_table(:some_table)
    KVDataStore.put(:some_table, "one", 1)

    assert KVDataStore.get(:some_table, "one") == {:ok, 1}
  end

  test "set multiple and get" do
    KVDataStore.new_table(:some_table)
    assert KVDataStore.is_table_defined(:some_table) == {:ok, :some_table}
    KVDataStore.put(:some_table, "one", 1)
    KVDataStore.put(:some_table, :two, 2)

    assert KVDataStore.get(:some_table, "two") == {:error, :not_found}
    assert KVDataStore.get(:some_table, :two) == {:ok, 2}
  end

  test "set and delete" do
    KVDataStore.new_table(:some_table)
    KVDataStore.put(:some_table, :something, "something")

    assert KVDataStore.get(:some_table, :something) == {:ok, "something"}

    assert KVDataStore.delete(:some_table, :something)
    assert KVDataStore.get(:some_table, :something) == {:error, :not_found}
  end

  test "set and update" do
    KVDataStore.new_table(:some_table)
    KVDataStore.put(:some_table, :one, 1)

    assert KVDataStore.get(:some_table, :one) == {:ok, 1}

    KVDataStore.update(:some_table, :one, "one")
    assert KVDataStore.get(:some_table, :one) == {:ok, "one"}
  end

end
