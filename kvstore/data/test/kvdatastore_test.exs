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
  @table_name :data_table

  test "add table and check if the tables are defined or not" do
    KVDataStore.new_table()
    assert KVDataStore.is_table_defined(@table_name) == {:ok, @table_name}
    assert KVDataStore.is_table_defined(:some_table) == {:error, :none_found}
  end

  test "initialize, set 1 and get it" do
    KVDataStore.new_table()
    KVDataStore.put("one", "1")

    assert KVDataStore.get("one") == {:ok, "1"}
  end

  test "set multiple and get" do
    KVDataStore.new_table()
    assert KVDataStore.is_table_defined(@table_name) == {:ok, @table_name}
    KVDataStore.put("one", "1")
    KVDataStore.put(":two", "2")

    assert KVDataStore.get("two") == {:error, :not_found}
    assert KVDataStore.get(":two") == {:ok, "2"}
  end

  test "set and delete" do
    KVDataStore.new_table()
    KVDataStore.put(":something", "something")

    assert KVDataStore.get(":something") == {:ok, "something"}

    assert KVDataStore.delete(":something")
    assert KVDataStore.get(":something") == {:error, :not_found}
  end

  test "set and update" do
    KVDataStore.new_table()
    KVDataStore.put(":one", "1")

    assert KVDataStore.get(":one") == {:ok, "1"}

    KVDataStore.update(":one", "one")
    assert KVDataStore.get(":one") == {:ok, "one"}
  end

end
